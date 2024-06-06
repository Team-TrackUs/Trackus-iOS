//
//  ChatRoomVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/1/24.
//

import UIKit
import FirebaseFirestore

class ChatRoomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var chat: Chat
    private var messageMap: [MessageMap] = [] {
        didSet {
        }
    }
    private var messages: [Message] = [] // 메시지 배열
    
    var lock = NSRecursiveLock()
    
    private var listener: ListenerRegistration?
    let currentUid = User.currentUid
    let db = Firestore.firestore().collection("chats")
    
    init(chat: Chat) {
        self.chat = chat
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
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
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 리스너 종료
        stopListening()
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStackView.topAnchor),
            
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inputStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            plusButton.heightAnchor.constraint(equalToConstant: 36),
            plusButton.widthAnchor.constraint(equalToConstant: 36),
            
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            
            messageTextView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendMessage() {
        guard let text = messageTextView.text, !text.isEmpty else { return }
        let newMessage = Message(sendMember: currentUid, timeStamp: Date(), messageType: .text, data: text)
        
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
            _ = chat.members.map{
                // 해당 사용자 메세지 정보에 저장
                let db = db.document(chat.uid).collection($0.key)
                sendMessageFireStore(db: db, message: newMessage)
            }
        }
        
        // 안읽은 메세지수 갱신
        var usersUnreadCountInfo = chat.usersUnreadCountInfo.mapValues { $0 + 1 }
        usersUnreadCountInfo[currentUid] = 0
        db.document(chat.uid).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
    }
    
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
//        db.addDocument(data: [
//            "sendMember": message.sendMember,
//            "timeStamp": message.timeStamp,
//            "messageType": message.messageType,
//            "text": message.text!
//        ]) { error in
//            if let error = error {
//                print("Error adding message: \(error)")
//            } else {
//                DispatchQueue.main.async {
//                    self.messageTextField.text = nil
//                    self.scrollToBottom()
//                }
//            }
//        }
    }
    
    /// 채팅방 리스너 추가
    private func startListening() {
        listener = db.document(chat.uid).collection(currentUid)
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
    
    /// 채팅방 리스너 제거
    private func stopListening() {
        listener?.remove()
    }
    
    private func scrollToBottom() {
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
