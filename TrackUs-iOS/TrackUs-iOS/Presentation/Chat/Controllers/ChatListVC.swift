//
//  MyChatListVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import FirebaseFirestore

class ChatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //var chat = ChatRoomManager.shared
    
    private lazy var chatListTableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: "ChatRoomCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 72
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //chat.dummyData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatList), name: .newMessageCountDidChange, object: nil)
        setupNavBar()
        view.backgroundColor = .systemBackground
        chatListTableView.delegate = self
        setupAutoLayout()
    }

    private func setupNavBar() {
        self.navigationItem.title = "채팅 목록"
        self.navigationItem.titleView?.tintColor = .label
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
        self.view.addSubview(chatListTableView)
        
        NSLayoutConstraint.activate([
            chatListTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            chatListTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatListTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    // 채팅방 정보 변할때 UI 업데이트
    @objc private func updateChatList() {
        DispatchQueue.main.async {
            self.chatListTableView.reloadData()
        }
    }
    
    // MARK: - view 관련 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomCell
        let chatRoom = ChatManager.shared.chatRooms[indexPath.row]
        cell.configure(with: chatRoom, users: ChatManager.shared.userInfo)
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomVC = ChatRoomVC(chatUId: ChatManager.shared.chatRooms[indexPath.row].uid)
        chatRoomVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "나가기") { [self] (action, view, completionHandler) in
            // 나가기 함수 추가
            let chat = ChatManager.shared.chatRooms[indexPath.row]
            didSelectLeaveChatRoom(chat: chat)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ChatManager.shared.chatRooms.count == 0 {
            let label = UILabel(frame: tableView.bounds)
            label.text = "참여한 채팅방이 없습니다"
            label.textAlignment = .center
            label.textColor = .gray3
            tableView.backgroundView = label
            return 0
        } else {
            tableView.backgroundView = nil
            return ChatManager.shared.chatRooms.count
        }
        //return chat.chatRooms.count
    }
    
    func didSelectLeaveChatRoom(chat: Chat) {
        let db = Firestore.firestore().collection("chats")
        let currentUserUid = User.currentUid
        // 채팅방 나가기
        db.document(chat.uid).updateData([
            "members.\(currentUserUid)": false
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        // 안읽은 메세지수 카운터 제거
        if chat.group {
            db.document(chat.uid).updateData([
                "usersUnreadCountInfo.\(currentUserUid)": FieldValue.delete()
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                }
            }
        } else { // 개인채팅
            db.document(chat.uid).updateData([
                "usersUnreadCountInfo.\(currentUserUid)": 0
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                }
            }
        }
        
        // firebase 본인 채팅 저장소 삭제 -> 코어데이터 적용시 수정
        db.document(chat.uid).collection(currentUserUid).getDocuments { snapshot, error in
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
            }
        }
    }
}
