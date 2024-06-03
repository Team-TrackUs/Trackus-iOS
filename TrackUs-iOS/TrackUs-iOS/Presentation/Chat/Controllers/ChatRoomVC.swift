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
    private var listener: ListenerRegistration?
    var messages: [Message] = [] // 메시지 배열
    var currentUid = User.currentUid
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        return tableView
    }()
    
    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "대화를 입력해주세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("전송", for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var inputStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [messageTextField, sendButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListening()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(inputStackView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStackView.topAnchor),
            
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inputStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            messageTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
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
                    self.messageTextField.text = nil
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
                self.tableView.reloadData()
                if !self.messages.isEmpty {
                    self.scrollToBottom()
                }
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        let message = messages[indexPath.row]
        let isMyMessage = message.sendMember == currentUid
        let messageView = ChatMessageView(message: message, isMyMessage: isMyMessage)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(messageView)
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            messageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            messageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
