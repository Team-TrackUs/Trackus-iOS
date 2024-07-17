//
//  ChatRoomVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/1/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

import MapKit

class ChatRoomVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    private var chatUId: String
    private var chat: Chat
    private var newChat: Bool
    private var messageMap: [MessageMap] = []
    private var messages: [Message] = [] // 메시지 배열
    // ChatManager에 있는 데이터 활용 용도 -> 리스너 활용
    private var currentChatInfo: Chat {
        if let chat = ChatManger.chatRooms.first(where: { $0.uid == chatUId }){
            return chat
        }
        return self.chat
    }
    
    private var ChatManger = ChatManager.shared
    
    // 메인 버튼 하단 위치 제약조건
    private var tableViewBottomConstraint: NSLayoutConstraint!
    private var inputViewBottomConstraint: NSLayoutConstraint!
    private var messageTextViewHeightConstraint: NSLayoutConstraint!
    private var stackViewHeightConstraint: NSLayoutConstraint!
    private var collectionViewTopConstraint: NSLayoutConstraint!
    
    var lock = NSRecursiveLock()
    
    // firebase 관련
    private var listener: ListenerRegistration?
    private let currentUserUid = User.currentUid
    private let db = Firestore.firestore().collection("chats")
    
    // 하단 버튼 관련
    private let buttonData = [
        ("photo", "앨범", UIColor.interval),
        ("camera.fill", "카메라", UIColor.mainBlue),
            ("map", "지도", UIColor.subBlue)
            ]
    private var showButton: Bool = false{
        didSet{
            if showButton {
                    inputViewBottomConstraint.constant = -110
                collectionViewTopConstraint.constant = 0
                    collectionView.isHidden = false
                    plusButton.setImage(UIImage(systemName: "xmark")?.withTintColor(.gray2), for: .normal)
                view.endEditing(true)
                    //hideKeyboard()
            } else {
                    inputViewBottomConstraint.constant = -10
                collectionViewTopConstraint.constant = 130
                    //collectionView.isHidden = true
                    plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /// 그룹채팅용
    init(chatUId: String, newChat: Bool = false) {
        self.chat = {
            if let chat = ChatManager.shared.chatRooms.first(where: { $0.uid == chatUId }){
                return chat
            }
            // 없을 경우 새로 불러오기
            return Chat(uid: chatUId, group: true, title: "", members: [:], usersUnreadCountInfo: [:])
        }()
        self.chatUId = chatUId
        self.newChat = newChat
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 개인채팅용
    init(chat: Chat, newChat: Bool = false) {
        self.chat = chat
        self.chatUId = chat.uid
        self.newChat = newChat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "messageCell")
        return tableView
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")?.withTintColor(.gray2)
        button.tintColor = .gray2
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        //textField.numberOfLines = 0
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "paperplane.circle.fill")?.withTintColor(.mainBlue).resize(width: 36, height: 36)
        button.setImage(image, for: .normal)
        button.tintColor = .mainBlue
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(sendButtionTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageInputView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 19
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.gray3.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatManager.shared.currentChatUid = chatUId
        
        startListening()
        resetUnreadCounter()
        
        // 레이아웃 관련
        setupViews()
        setupNavigationBar()
        BlockedCheck()
        
        // 탭 제스처 인식기를 생성합니다.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // 제스처 인식기가 뷰의 다른 터치 이벤트를 방해하지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        // 뷰에 제스처 인식기를 추가
        tableView.addGestureRecognizer(tapGesture)
        
        // 스와이프로 이전 화면 갈 수 있도록 추가
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        // 키보드 메소드 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 뷰가 다시 나타날 때마다 호출
        startListening()
        BlockedCheck()
        ChatManager.shared.currentChatUid = chatUId
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 리스너 종료
            ChatManger.currentChatUid = ""
            stopListening()
            resetUnreadCounter()
    }
    // MARK: - 오토레이아웃 관련
    private func setupNavigationBar() {
        let sideMenuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(showSideMenu))
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        
        sideMenuButton.tintColor = .gray1
        backButton.tintColor = .gray1
        
        navigationItem.rightBarButtonItem = sideMenuButton
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = chat.group ? chat.title : ChatManger.userInfo[chat.nonSelfMembers[0]]?.name
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        view.addSubview(collectionView)
        messageInputView.addSubview(plusButton)
        messageInputView.addSubview(messageTextView)
        messageInputView.addSubview(sendButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomButtonCell.self, forCellWithReuseIdentifier: "CustomButtonCell")
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -4)
        inputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        collectionViewTopConstraint = collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 130)
        
        stackViewHeightConstraint = messageInputView.heightAnchor.constraint(equalToConstant: 38)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint,
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackViewHeightConstraint,
            inputViewBottomConstraint,
            
            plusButton.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor),
            plusButton.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: -1),
            plusButton.heightAnchor.constraint(equalToConstant: 38),
            plusButton.widthAnchor.constraint(equalToConstant: 38),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor),
            sendButton.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 38),
            sendButton.widthAnchor.constraint(equalToConstant: 38),
            
            messageTextView.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 2),
            messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -2),
            messageTextView.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 1),
            messageTextView.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: -1),
            
            //collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 100),
            collectionViewTopConstraint
        ])
    }
    
    func BlockedCheck() {
        if !chat.group ,let blockedUserList = UserManager.shared.user.blockedUserList, let opponentUid = chat.nonSelfMembers.first, blockedUserList.contains(opponentUid) {
            messageTextView.isEditable = false
            messageTextView.text = "차단 사용자와는 대화가 불가능합니다."
            messageTextView.textColor = .gray2
            sendButton.isEnabled = false
        } else {
            messageTextView.isEditable = true
            messageTextView.text = ""
            messageTextView.textColor = .label
            sendButton.isEnabled = true
        }
    }
    
    // MARK: - 액션 관련 함수
    // 전송 버튼 이벤트 함수
    @objc private func sendButtionTapped() {
        guard !UserManager.shared.user.isBlock else {
            let alertController = UIAlertController(title: "메세지 전송 제한", message: "사용자 계정 이용이 제한되어 채팅이 불가능합니다.", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let reportCount = UserManager.shared.user.reportIDList, reportCount.count > 3 {
            let alertController = UIAlertController(title: "메세지 전송 제한", message: "신고로 인해 채팅이 일시 제한되었습니다.\n\n자세한 내용은 아래 메일을 통해\n문의해주시기 바랍니다.\nteam.trackus@gmail.com", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let text = messageTextView.text, !text.isEmpty else { return }
        let newMessage = Message(sendMember: currentUserUid, timeStamp: Date(), messageType: .text, data: text)
        sendMessage(newMessage: newMessage)
    }
    
    
    
    // 사이드 메뉴 보이기
    @objc private func showSideMenu() {
        let sideMenuVC = SideMenuVC(chat: currentChatInfo)
        sideMenuVC.delegate = self
        sideMenuVC.profileImageDelegate = self
        sideMenuVC.modalPresentationStyle = .overFullScreen
        present(sideMenuVC, animated: false) {
            sideMenuVC.showMenu()
        }
    }
    
    // 키보드 나타날 때
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 키보드 높이만큼 bottom constraint 조정
            showButton = false
            inputViewBottomConstraint.constant = 25 - keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        }
    }
    
    // 키보드 사라질 때
    @objc private func keyboardWillHide(notification: NSNotification) {
        // 키보드가 사라질 때 원래대로 복귀
        if !showButton {
            inputViewBottomConstraint.constant = -10
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    /// 키보드 숨기기
    @objc func hideKeyboard() {
        // 모든 입력 필드의 편집을 종료하고 키보드를 숨깁니다.
        view.endEditing(true)
        if showButton {
            showButton = false
        }
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 플러스 버튼 액션
    @objc private func plusButtonTapped() {
        showButton.toggle()
    }
    
    // MARK: -
    private func sendMessage(newMessage: Message){
        if let chat = ChatManger.currentChatInfo {
            self.chat = chat
        }
        
        if chat.group {
            // 그룹 메세지 - 각 사용자별 메세지 저장소에 저장
            _ = chat.members.map{
                // 참여중인 사용자 확인
                if $0.value == true {
                    // 해당 사용자 메세지 정보에 저장
                    sendMessageFireStore(message: newMessage, opponentUid: $0.key)
                }
            }
        }else { // 개인 채팅
            // 상대방 계정 정지여부 확인
            guard let opponentUid = chat.nonSelfMembers.first, let userInfo = ChatManger.userInfo[opponentUid], !userInfo.isBlock else {
                // 개인 채팅일 경우 상대방 계정 정지 여부 alert으로 알림
                if !currentChatInfo.group {
                    let alertController = UIAlertController(title: "전송 실패", message: "상대의 계정 사용이 제한되어\n더 이상 메세지를 전송할 수 없습니다.", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "확인", style: .default)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            // 상대방 차단여부 확인
            if !chat.group ,let blockingMeList = UserManager.shared.user.blockingMeList, let opponentUid = chat.nonSelfMembers.first, blockingMeList.contains(opponentUid) {
                // 상대방이 차단했을 경우 -> 나에게만 전송
                if newChat {
                    chat.members[opponentUid] = false
                    createChatRoom { [self] in
                        sendMessageFireStore(message: newMessage, opponentUid: currentUserUid)
                        newChat.toggle()
                    }
                    startListening()
                } else {
                    sendMessageFireStore(message: newMessage, opponentUid: currentUserUid)
                }
            } else {
                // 신규 채팅의 경우
                if newChat {
                    createChatRoom { [self] in
                        _ = chat.members.map{
                            sendMessageFireStore(message: newMessage, opponentUid: $0.key)
                        }
                        newChat.toggle()
                    }
                    startListening()
                }else {
                    
                    // 나간 여부로 되어있을 경우 true 처리
                    if chat.members.values.contains(false) {
                        for key in chat.members.keys {
                            chat.members[key] = true
                        }
                        db.document(chatUId).updateData([
                            "members": chat.members
                        ]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                    
                    _ = chat.members.map{
                        sendMessageFireStore(message: newMessage, opponentUid: $0.key)
                    }
                }
            }
        }
        
        updateLatesMessage(message: newMessage)
        
        if let chat = ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == chatUId }){
            // 기존 채팅방 띄우기
            var usersUnreadCountInfo = chat.usersUnreadCountInfo.mapValues { $0 + 1 }
            usersUnreadCountInfo[currentUserUid] = 0
            db.document(chat.uid).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
        } else {
            // 초반 리스너 파일 불러와지기 전 업데이트 용도
            var usersUnreadCountInfo = chat.usersUnreadCountInfo.mapValues { $0 + 1 }
            usersUnreadCountInfo[currentUserUid] = 0
            db.document(chat.uid).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
        }
    }
    
    
    // MARK: - Firebase 관련 함수
    // 메세지 전송
    private func sendMessageFireStore(message: Message, opponentUid: String) {
        // 제한 사용자에게는 메세지 전송 x
        if let userInfo = ChatManger.userInfo[opponentUid], userInfo.isBlock {
            return
        }
        
        let db = db.document(chat.uid).collection(opponentUid)
        db.addDocument(data: [
            "sendMember": message.sendMember,
            "timeStamp": message.timeStamp,
            "text": message.text as Any,
            "imageUrl": message.imageUrl as Any,
            "location": message.location as Any,
            "userInOut": message.userInOut as Any
        ]) { error in
            if let error = error {
                print("Error adding message: \(error)")
            } else {
                DispatchQueue.main.async {
                    if opponentUid != self.currentUserUid && message.messageType != .userInout {
                        self.sendFCMNotification(to: opponentUid, message: message)
                    }
                    self.messageTextView.text = nil
                    self.scrollToBottom()
                }
            }
        }
    }
    
    private func sendFCMNotification(to OpponentUid: String, message: Message) {
        // 서버 주소값 불러오기
        guard let baseUrlString = Bundle.main.object(forInfoDictionaryKey: "FCM_NOTIFICATION_SERVER_URL") as? String else { return }
        let urlString = "https://" + baseUrlString
        guard let url = URL(string: urlString), let token = ChatManger.userInfo[OpponentUid]?.token else { return }
        var body: String
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        switch message.messageType {
            case .text:
                body = message.text!
            case .image:
                body = "사진을 보냈습니다."
            case .location:
                body = "위치 장소를 보냈습니다."
            case .userInout:
                return
        }

        let message: [String: Any] = [
            "token": token,
            "title": chat.group ? chat.title : UserManager.shared.user.name,
            "body": body,
            // 메세지 전송 이미지
            "imageUrl": message.imageUrl ?? "",
            // 채팅방 식별용
            "chatUid": chatUId,
            "profileUrl": UserManager.shared.user.profileImageUrl ?? ""
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            request.httpBody = jsonData
        } catch {
            print("Error: unable to create JSON data")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                print("Server error: \(response.statusCode)")
                return
            }

            if let data = data, let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Response JSON: \(responseJSON)")
            }
        }

        task.resume()
    }
    
    private func sendImage(image: UIImage) {
        // fireStorage 이미지 등록
        let ref = Storage.storage().reference().child("chatImages/\(UUID())")
        // 이미지 포멧 JPEG 변경
        guard let jpegData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 storage에 저장
        ref.putData(jpegData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to push image to Storage: \(error)")
                return
            }
            // url 받아오기
            ref.downloadURL { url, error in
                if let error = error{
                    print("Failed to retrieve downloadURL: \(error)")
                    return
                }
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                
                // 이미지 url 저장
                guard let url = url else { return }
                let imageUrl = url.absoluteString
                ImageCacheManager.shared.setImage(image: image, url: imageUrl)
                
                // 이미지 전송 함수
                let newMessage = Message(sendMember: self.currentUserUid, timeStamp: Date(), messageType: .image, data: imageUrl)
                // 이미지 url 포함 메세지 전송
                self.sendMessage(newMessage: newMessage)
                return
            }
        }
    }
    
    // 본인 신규 메세지 갯수 초기화
    private func resetUnreadCounter() {
        if let chat = ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == chatUId }){
            var usersUnreadCountInfo = chat.usersUnreadCountInfo
            usersUnreadCountInfo[currentUserUid] = 0
            db.document(chat.uid).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
        }
    }
    
    // 최근 메세지 업데이트
    private func updateLatesMessage (message: Message) {
        if message.messageType == .userInout { return }
        var text: String
        switch message.messageType {
            case .text:
                text = message.text!
            case .image:
                text = "사진을 보냈습니다."
            case .location:
                text = "위치 장소를 보냈습니다."
            case .userInout:
                return
        }
        let latestMessageData : [String: Any] = [
            "text": text,
            // 이미지 작업 추가하면 해당 수정
            "timestamp": Date() // 현재 시간을 타임스탬프로 변환
        ]
        db.document(chat.uid).updateData(["latestMessage" : latestMessageData])
    }
    
    /// 채팅방 리스너 추가
    private func startListening() {
        listener = db.document(chat.uid).collection(currentUserUid)
            .order(by: "timeStamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let firestoreMessages = documents
                    .compactMap { try? $0.data(as: FirestoreMessage.self)}
                    .compactMap{ firestoreMessage -> Message? in
                        return Message(firestoreMessage: firestoreMessage)
                    }
                self.messages = firestoreMessages
                // 메세지 맵핑
                self.lock.withLock {
                    self.messageMap = self.messageMapping(self.messages)
                }
                print(messageMap)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !self.messageMap.isEmpty {
                        self.scrollToBottom()
                    }
                }
            }
    }
    
    /// 메세지 맵핑용 -> 동일 사용자, 시간별 맵핑
    func messageMapping(_ messages: [Message]) -> [MessageMap] {
        //var result: [MessageMap] = []
        
        messages
            .enumerated()
            .map{
                //let nextMessageExists = messages[$0.offset + 1] != nil
                let prevMessageIsSameUser = $0.offset != 0 ? messages[$0.offset - 1].sendMember == $0.element.sendMember && messages[$0.offset - 1].messageType != .userInout  : false
                let sameDate = $0.offset != 0 ? messages[$0.offset - 1].date == $0.element.date : false
                let nextMessageIsSameUser = $0.offset != messages.count - 1 ? messages[$0.offset + 1].sendMember == $0.element.sendMember : false
                let sameTime = $0.offset != messages.count - 1 && $0.offset != 0  ? messages[$0.offset + 1].time == $0.element.time : false
                
                return MessageMap(message: $0.element, sameUser: prevMessageIsSameUser, sameDate: sameDate, sameTime: nextMessageIsSameUser && sameTime)
            }
    }
    // 개인 신규 채팅방 생성하기
    private func createChatRoom(completionHandler: @escaping () -> Void) {
        let newChatRoom: [String: Any] = [
            "title": chat.title,
            "group": false,
            "members": chat.members,
            "usersUnreadCountInfo": chat.usersUnreadCountInfo
            //"latestMessage": nil
        ]  as [String : Any]
        Firestore.firestore().collection("chats").document(chat.uid).setData(newChatRoom)
        completionHandler()
    }
    
    /// 채팅방 리스너 제거
    private func stopListening() {
        listener?.remove()
    }
    
    /// 스크롤뷰 하단으로 내리기
    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        
        let messageMap = messageMap[indexPath.row]
        cell.configure(messageMap: messageMap)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatRoomVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트 뷰의 크기를 콘텐츠에 맞게 조정
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        // 최대 3줄 높이 계산
        let maxHeight: CGFloat = 4 * textView.font!.lineHeight
        let height = min(estimatedSize.height, maxHeight)
        
        messageTextViewHeightConstraint?.constant = height
        stackViewHeightConstraint.constant = height > 38 ? height+4 : 38
        
        textView.isScrollEnabled = estimatedSize.height >= maxHeight
        view.layoutIfNeeded()
    }
}

// 사이드바
extension ChatRoomVC: SideMenuDelegate {
    func didSelectCourseDetail(postID: String) {
        
        let courseDetailVC = CourseDetailVC(isBack: true)
        courseDetailVC.hidesBottomBarWhenPushed = true

        courseDetailVC.postUid = chat.uid

        self.navigationController?.pushViewController(courseDetailVC, animated: true)
    }
    
    // 나가기 버튼 함수
    func didSelectLeaveChatRoom(chatRoomID: String) {
        // 채팅방 나가기
        db.document(chatRoomID).updateData([
            "members.\(currentUserUid)": false
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        // 안읽은 메세지수 카운터 제거
        if chat.group {
            db.document(chatRoomID).updateData([
                "usersUnreadCountInfo.\(currentUserUid)": FieldValue.delete()
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                }
            }
        } else { // 개인채팅
            db.document(chatRoomID).updateData([
                "usersUnreadCountInfo.\(currentUserUid)": 0
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                }
            }
        }
        
        // firebase 본인 채팅 저장소 삭제 -> 코어데이터 적용시 수정
        db.document(chatRoomID).collection(currentUserUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            
            let batch = Firestore.firestore().batch()
            snapshot.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { batchError in
            }
        }
        
        // 나가기 안내 메세지
        let newMessage = Message(sendMember: currentUserUid, timeStamp: Date(), messageType: .userInout, data: false)
        
        // 그룹 채팅방만 해당
        if chat.group {
            // 그룹 메세지 - 각 사용자별 메세지 저장소에 저장
            _ = chat.members.map{
                // 참여중인 사용자 확인
                if $0.value == true {
                    // 해당 사용자 메세지 정보에 저장
                    sendMessageFireStore(message: newMessage, opponentUid: $0.key)
                }
            }
        }
        
        // 채팅방 view 나가기
        self.navigationController?.popViewController(animated: true)
    }
}
    
extension ChatRoomVC: ChatMessageCellDelegate{
    // 사용자 프로필 이미지 탭했을 경우
    func didTapProfileImage(for uid: String) {
        if currentUserUid != uid {
            let otherProfileVC = OtherProfileVC(userId: uid)
            navigationController?.pushViewController(otherProfileVC, animated: true)
        } else {
            let myProfileVC = MyProfileVC()
            navigationController?.pushViewController(myProfileVC, animated: true)
        }
    }
    
    // 사용자 전송 이미지 탭했을 경우
    func didTapImageMessage(for userName: String, dateString: String, image: UIImage?) {
        guard let image = image else { return }
        let detailVC = ImageDetailVC()
        detailVC.image = image
        detailVC.imageName = userName
        detailVC.imageDate = dateString
        //self.navigationController?.pushViewController(detailVC, animated: true)
        let navController = UINavigationController(rootViewController: detailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    // map 상세보기 버튼 탭했을 경우
    func didTapMapMessage(for coordinate: CLLocationCoordinate2D) {
        let detailVC = DetailMapViewController()
        detailVC.coordinate = coordinate
        navigationController?.pushViewController(detailVC, animated: true)
        
//        let navController = UINavigationController(rootViewController: detailVC)
//        navController.modalPresentationStyle = .fullScreen
//        present(navController, animated: true, completion: nil)
    }
}

// MARK: - 하단 메뉴 컬랙션뷰
extension ChatRoomVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomButtonCell", for: indexPath) as! CustomButtonCell
        let data = buttonData[indexPath.item]
        cell.configure(imageName: data.0, labelText: data.1, backgroundColor: data.2)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 4, height: 80)
    }
    
    // 컬렉션 뷰 아이템 탭 이벤트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
            case 0: // 앨범
                let imagePickerVC = ImagePickerVC()
                self.navigationController?.pushViewController(imagePickerVC, animated: true)
                imagePickerVC.delegate = self
            case 1: // 카메라
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true, completion: nil)
            case 2: // 지도
                let SendMapVC = SendLocationVC()
                navigationController?.pushViewController(SendMapVC, animated: true)
                SendMapVC.delegate = self
            default:
                return
        }
    }
}

extension ChatRoomVC: ImagePickerDelegate{
    // 앨범 선택 전송
    func imagePicker(_ picker: ImagePickerVC, didSelectImage image: UIImage) {
        // 이미지 전송 함수
        sendImage(image: image)
    }
}

extension ChatRoomVC: UIImagePickerControllerDelegate{
    // 사진 촬영 전송
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            sendImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatRoomVC: LocationSelectionDelegate{
    func didSelectLocation(latitude: Double, longitude: Double) {
        let geoPoint = GeoPoint(latitude: latitude, longitude: longitude)
        // 위치값 전송
        let newMessage = Message(sendMember: self.currentUserUid, timeStamp: Date(), messageType: .location, data: geoPoint)
        // 이미지 url 포함 메세지 전송
        self.sendMessage(newMessage: newMessage)
    }
}
