//
//  ChatRoomVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/1/24.
//

import UIKit
import FirebaseFirestore

class ChatRoomVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    private var chatUId: String
    private var chat: Chat
    private var newChat: Bool
    private var messageMap: [MessageMap] = []
    private var messages: [Message] = [] // 메시지 배열
    
    private var userInfo = ChatManager.shared.userInfo
    // 사용자 차단 여부
    private var blackStatus: Bool = false
    
    // 메인 버튼 하단 위치 제약조건
    private var tableViewBottomConstraint: NSLayoutConstraint!
    private var inputViewBottomConstraint: NSLayoutConstraint!
    private var messageTextViewHeightConstraint: NSLayoutConstraint!
    private var stackViewHeightConstraint: NSLayoutConstraint!
    
    var lock = NSRecursiveLock()
    
    private var listener: ListenerRegistration?
    let currentUserUid = User.currentUid
    let db = Firestore.firestore().collection("chats")
    
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
        if !chat.group ,let blockedUserList = UserManager.shared.user.blockedUserList, let opponentUid = chat.nonSelfMembers.first, blockedUserList.contains(opponentUid) {
            self.blackStatus = true
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 개인채팅용
    init(chat: Chat, newChat: Bool = false) {
        self.chat = chat
        self.chatUId = chat.uid
        self.newChat = newChat
        if let blockedUserList = UserManager.shared.user.blockedUserList, let opponentUid = chat.nonSelfMembers.first, blockedUserList.contains(opponentUid) {
            self.blackStatus = true
        }
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
        let image = UIImage(systemName: "plus")?.withTintColor(.gray2).resize(width: 18, height: 18)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.isEditable = blackStatus ? false : true
        textView.text = blackStatus ? "차단 사용자와는 대화가 불가능합니다." : ""
        textView.textColor = blackStatus ? .gray2 : .label
        //textField.numberOfLines = 0
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        //button.setTitle("전송", for: .normal)
        let image = UIImage(systemName: "paperplane.circle.fill")?.withTintColor(.mainBlue).resize(width: 36, height: 36)
        button.isEnabled = blackStatus ? false : true
        button.setImage(image, for: .normal)
        button.tintColor = .mainBlue
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatManager.shared.currentChatUid = chatUId
        
        startListening()
        resetUnreadCounter()
        
        // 레이아웃 관련
        setupViews()
        setupNavigationBar()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 리스너 종료
        ChatManager.shared.currentChatUid = ""
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
        navigationItem.title = chat.group ? chat.title : userInfo[chat.nonSelfMembers[0]]?.name
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        messageInputView.addSubview(plusButton)
        messageInputView.addSubview(messageTextView)
        messageInputView.addSubview(sendButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        messageTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -4)
        inputViewBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)

        stackViewHeightConstraint = messageInputView.heightAnchor.constraint(equalToConstant: 38)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint,

            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            //messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
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
        ])
    }
    
    // MARK: - 액션 관련 함수
    // 전송 버튼 이벤트 함수
    @objc private func sendMessage() {
        guard let text = messageTextView.text, !text.isEmpty else { return }
        let newMessage = Message(sendMember: currentUserUid, timeStamp: Date(), messageType: .text, data: text)
        // 신규 채팅일 경우
        
        
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
            // 상대방 차단여부 확인
            if !chat.group ,let blockingMeList = UserManager.shared.user.blockingMeList, let opponentUid = chat.nonSelfMembers.first, blockingMeList.contains(opponentUid) {
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
                
                // 본인에게만 전송
            } else {
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
    
    
    
    // 사이드 메뉴 보이기
    @objc private func showSideMenu() {
        let sideMenuVC = SideMenuVC(chat: chat)
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
        inputViewBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 키보드 숨기기
    @objc func hideKeyboard() {
        // 모든 입력 필드의 편집을 종료하고 키보드를 숨깁니다.
        view.endEditing(true)
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Firebase 관련 함수
    // 메세지 전송
    private func sendMessageFireStore(message: Message, opponentUid: String) {
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
        let urlString = "https://sendfcmnotification-p5womzw3ra-uc.a.run.app/sendFCMNotification"
        guard let url = URL(string: urlString), let token = userInfo[OpponentUid]?.token else { return }
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
                let prevMessageIsSameUser = $0.offset != 0 ? messages[$0.offset - 1].sendMember == $0.element.sendMember : false
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
    
extension ChatRoomVC: UserCellDelegate{
    func didTapProfileImage(for uid: String) {
        let otherProfileVC = OtherProfileVC(userId: uid)
        navigationController?.pushViewController(otherProfileVC, animated: true)
    }
}
