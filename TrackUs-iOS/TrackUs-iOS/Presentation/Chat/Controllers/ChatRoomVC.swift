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
    private var newChat: Bool{
        didSet{
            subscribeChat(chatUid: chatUId) { chat in
                self.chat = chat
            }
        }
    }
    private var messageMap: [MessageMap] = []
    private var messages: [Message] = [] // 메시지 배열
    
    private var userInfo = ChatRoomManager.shared.userInfo
    
    // 메인 버튼 하단 위치 제약조건
    private var inputStackViewBottomConstraint: NSLayoutConstraint!
    
    var lock = NSRecursiveLock()
    
    private var listener: ListenerRegistration?
    let currentUserUid = User.currentUid
    let db = Firestore.firestore().collection("chats")
    
    /// 그룹채팅용
    init(chatUId: String, newChat: Bool = false) {
        self.chat = {
            if let chat = ChatRoomManager.shared.chatRooms.first(where: { $0.uid == chatUId }){
                return chat
            }
            // 없을 경우 새로 불러오기
            return Chat(uid: chatUId, group: true, title: "", members: [:], usersUnreadCountInfo: [:])
        }()
        self.chatUId = chatUId
        self.newChat = newChat
        if newChat {
            
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 개인채팅용
    init(chat: Chat, newChat: Bool = false) {
        self.chat = chat
        self.chatUId = chat.uid
        self.newChat = newChat
        if newChat {
            
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    // 채팅방 정보 불러오기 용도
    private func subscribeChat(chatUid: String, completionHandler: @escaping (Chat) -> Void) {
        let ref = Firestore.firestore().collection("chats")
        ref.document(chatUid).addSnapshotListener(){ [weak self] (snapshot, _) in
            guard let document = snapshot, document.exists else {
                return
            }
            do {
            let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                guard let chat = self?.makeChatRooms(firestoreChatRoom) else { return }
                completionHandler(chat)
            } catch {
                print(error)
            }
        }
    }
//    // 채팅방 Firebase 정보 가져오기
//    private func storeChatRooms(_ snapshot: QuerySnapshot?, _ currentUId: String) {
//        DispatchQueue.main.async { [weak self] in
//            self?.chatRooms = snapshot?.documents
//                .compactMap { [weak self] document in
//                    do {
//                        let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
//                        return self?.makeChatRooms(firestoreChatRoom, currentUId)
//                    } catch {
//                        print(error)
//                    }
//                    
//                    return nil
//                }.sorted {
//                    guard let date1 = $0.latestMessage?.timestamp, let date2 = $1.latestMessage?.timestamp else {
//                        return $0.title < $1.title
//                    }
//                    return date1 > date2
//                }
//            ?? []
//        }
//    }
//    
    // ChatRoom타입에 맞게 변환
    private func makeChatRooms(_ firestoreChatRoom: FirestoreChatRoom) -> Chat {
        var message: LastetMessage? = nil
        if let flm = firestoreChatRoom.latestMessage {
            message = LastetMessage(
                //senderName: user.name,
                timestamp: flm.timestamp,
                text: flm.text.isEmpty ? "사진을 보냈습니다." : flm.text
            )
        }
        _ = firestoreChatRoom.members.map { memberId in
            memberUserInfo(uid: memberId.key)
        }
        let chatRoom = Chat(
            uid: firestoreChatRoom.id ?? "",
            group: firestoreChatRoom.group,
            title: firestoreChatRoom.title,
            members: firestoreChatRoom.members,
            usersUnreadCountInfo: firestoreChatRoom.usersUnreadCountInfo,
            latestMessage: message
        )
        return chatRoom
    }
//    
    // 채팅방 멤버 닉네임, 프로필사진url 불러오기
    private func memberUserInfo(uid: String) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                // 탈퇴 사용자인 경우 리스트에서 삭제
//                self.chat = self.chatRooms.members.filter{
//                    var chatRoom = $0
//                    chatRoom.members = $0.members.filter{ $0.key != uid }
//                    return chatRoom
//                }
                return
            }
            do {
                let userInfo = try document.data(as: User.self)
                self.userInfo[uid] = userInfo
            } catch {
                print("Error decoding document: \(error)")
            }
        }
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
        textView.delegate = self
        //textField.numberOfLines = 0
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        //button.setTitle("전송", for: .normal)
        let image = UIImage(systemName: "paperplane.circle.fill")?.withTintColor(.mainBlue).resize(width: 36, height: 36)
        button.setImage(image, for: .normal)
        button.tintColor = .mainBlue
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.mainBlue.cgColor
        button.layer.borderWidth = 3
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [plusButton, messageTextView, sendButton])
        stackView.axis = .horizontal
        stackView.backgroundColor = .systemBackground
        stackView.spacing = 0
        stackView.layer.cornerRadius = 18
        stackView.clipsToBounds = true
        stackView.layer.borderColor = UIColor.gray3.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        stopListening()
        resetUnreadCounter()
    }

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
        view.addSubview(inputStackView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        
        inputStackViewBottomConstraint = inputStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStackView.topAnchor),
            
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inputStackViewBottomConstraint,
            
            plusButton.heightAnchor.constraint(equalToConstant: 36),
            plusButton.widthAnchor.constraint(equalToConstant: 36),
            
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            
            messageTextView.heightAnchor.constraint(equalToConstant: 40)
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
                    let db = db.document(chat.uid).collection($0.key)
                    sendMessageFireStore(db: db, message: newMessage)
                }
            }
        }else { // 개인 채팅
            // 차단 여부 추가
            if newChat {
                createChatRoom { [self] in
                    _ = chat.members.map{
                        // 해당 사용자 메세지 정보에 저장
                        let db = db.document(chat.uid).collection($0.key)
                        sendMessageFireStore(db: db, message: newMessage)
                    }
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
                    // 해당 사용자 메세지 정보에 저장
                    let db = db.document(chat.uid).collection($0.key)
                    sendMessageFireStore(db: db, message: newMessage)
                }
            }
        }
        
        
        if let chat = ChatRoomManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == chatUId }){
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
        
        sideMenuVC.modalPresentationStyle = .overFullScreen
        present(sideMenuVC, animated: false) {
            sideMenuVC.showMenu()
        }
    }
    
    // 키보드 나타날 때
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 키보드 높이만큼 bottom constraint 조정
            inputStackViewBottomConstraint.constant = 25 - keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // 키보드 사라질 때
    @objc private func keyboardWillHide(notification: NSNotification) {
        // 키보드가 사라질 때 원래대로 복귀
        inputStackViewBottomConstraint.constant = -10
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
    private func sendMessageFireStore(db: CollectionReference, message: Message) {
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
                    self.messageTextView.text = nil
                    self.scrollToBottom()
                }
            }
        }
    }
    
    // 본인 신규 메세지 갯수 초기화
    private func resetUnreadCounter() {
        if let chat = ChatRoomManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == chatUId }){
            var usersUnreadCountInfo = chat.usersUnreadCountInfo
            usersUnreadCountInfo[currentUserUid] = 0
            db.document(chat.uid).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
        }
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
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
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
                    let db = db.document(chat.uid).collection($0.key)
                    sendMessageFireStore(db: db, message: newMessage)
                }
            }
        }
        
        // 채팅방 view 나가기
        self.navigationController?.popViewController(animated: true)
    }
}
    
extension ChatRoomVC: ChatMessageCellDelegate{
    func didTapProfileImage(for uid: String) {
        let otherProfileVC = OtherProfileVC(userId: uid)
        navigationController?.pushViewController(otherProfileVC, animated: true)
    }
}
