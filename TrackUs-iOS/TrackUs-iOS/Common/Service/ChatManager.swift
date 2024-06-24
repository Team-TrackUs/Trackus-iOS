//
//  ChatManager.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/30/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatManager {
    static let shared = ChatManager()
    
    var chatRooms: [Chat] = []
    var userInfo: [String: User] = [:]
    
    var currentChatUid: String = ""
    
    var currentChatInfo: Chat? {
        if let chat = chatRooms.first(where: { $0.uid == currentChatUid }){
            return chat
        }
        return nil
    }
    
    // 신규 메세지 총 갯수
    var newMessageCount: String? = nil {
        didSet {
            NotificationCenter.default.post(name: .newMessageCountDidChange, object: nil)
        }
    }
    
    private let ref = Firestore.firestore().collection("chats")
    
    private init() {
        // Call subscribeToUpdates when the ChatManager is initialized
        subscribeToUpdates {
            print("Subscribed to chat updates")
        }
    }
    
    // MARK: - 채팅방 리스너 관련
    // 채팅방 listener 추가
    func subscribeToUpdates(completionHandler: @escaping () -> Void) {
        let currentUid = User.currentUid
        ref.whereField("members.\(currentUid)", isEqualTo: true).addSnapshotListener() { [weak self] (snapshot, _) in
            self?.storeChatRooms(snapshot, currentUid, completionHandler: completionHandler)
        }
    }
    
    // 채팅방 Firebase 정보 가져오기
    private func storeChatRooms(_ snapshot: QuerySnapshot?, _ currentUId: String, completionHandler: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        DispatchQueue.main.async { [weak self] in
            self?.chatRooms = snapshot?.documents
                .compactMap { [weak self] document in
                    do {
                        let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                        return self?.makeChatRooms(firestoreChatRoom, currentUId, dispatchGroup: dispatchGroup)
                    } catch {
                        print(error)
                    }
                    
                    return nil
                }.sorted {
                    guard let date1 = $0.latestMessage?.timestamp, let date2 = $1.latestMessage?.timestamp else {
                        return $0.title < $1.title
                    }
                    return date1 > date2
                }
            ?? []
            // 신규 메세지 갯수 합산
            if let count = self?.chatRooms.reduce (0, { $0 + ($1.usersUnreadCountInfo[User.currentUid] ?? 0) }){
                var newCount: String?
                switch count{
                    case 0 :
                        UIApplication.shared.applicationIconBadgeNumber = count
                    case 1...999: newCount = String(count)
                        UIApplication.shared.applicationIconBadgeNumber = count
                    case 999...: newCount = "999+"
                        UIApplication.shared.applicationIconBadgeNumber = 999
                    default: newCount = nil
                }
                self?.newMessageCount = newCount
            }
            dispatchGroup.notify(queue: .main) {
                completionHandler()
            }
        }
    }
    
    // ChatRoom타입에 맞게 변환
    private func makeChatRooms(_ firestoreChatRoom: FirestoreChatRoom, _ currentUId: String, dispatchGroup: DispatchGroup) -> Chat {
        var message: LastetMessage? = nil
        if let flm = firestoreChatRoom.latestMessage {
            message = LastetMessage(
                //senderName: user.name,
                timestamp: flm.timestamp,
                text: flm.text.isEmpty ? "사진을 보냈습니다." : flm.text
            )
        }
        firestoreChatRoom.members.forEach { memberId in
            dispatchGroup.enter()
            memberUserInfo(uid: memberId.key) {
                dispatchGroup.leave()
            }
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
    
    // 채팅방 멤버 닉네임, 프로필사진url 불러오기
    private func memberUserInfo(uid: String, completionHandler: @escaping () -> ()) {
        Firestore.firestore().collection("users").document(uid).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                // 탈퇴 사용자인 경우 리스트에서 삭제
                self.chatRooms = self.chatRooms.map{
                    var chatRoom = $0
                    chatRoom.members = $0.members.filter{ $0.key != uid }
                    return chatRoom
                }
                completionHandler()
                return
            }
            do {
                let userInfo = try document.data(as: User.self)
                self.userInfo[uid] = userInfo
                completionHandler()
            } catch {
                print("Error decoding document: \(error)")
                self.chatRooms = self.chatRooms.map{
                    var chatRoom = $0
                    chatRoom.members.removeValue(forKey: uid)
                    return chatRoom
                }
                completionHandler()
            }
        }
    }
    
    /// 1대1 채팅방 있는지 확인
    func joinChatRoom(opponentUid: String, completionHandler: @escaping (Chat, Bool) -> Void) {
        // 채팅방 정보, 신규 채팅방 여부 반환
        let currentUid = User.currentUid
        // 기존 채팅방 있는 경우
        if let chat = chatRooms.first(where: { chat in
            !chat.group && chat.nonSelfMembers.contains(opponentUid)
        }) {
            completionHandler(chat, false)
        }else {
            // 채팅방 없는 경우 firestore 확인
            ref.whereField("group", isEqualTo: false)
                .whereField("members.\(currentUid)", in: [false])
                .whereField("members.\(opponentUid)", in: [true, false])
                .getDocuments { [weak self] (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }
                    // 기존 채팅방 정보 있을 경우
                    if let document = querySnapshot?.documents.first, document.exists {
                        do {
                            let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                            if let chat = self?.makeChatRooms(firestoreChatRoom, currentUid, dispatchGroup: DispatchGroup()) {
                                self?.memberUserInfo(uid: opponentUid){
                                    completionHandler(chat, false)
                                }
                            }
                            return
                        } catch {
                            print("Error decoding document: \(error)")
                        }
                    }
                    
                    // 3. 1:1 채팅방이 없으면 새로운 채팅방 생성
                    let newChatRoom = Chat(
                        uid: UUID().uuidString,
                        group: false,
                        title: "", // 상대방 이름으로 설정하거나 다른 로직 추가 가능
                        members: [currentUid: true, opponentUid: true],
                        usersUnreadCountInfo: [currentUid: 0, opponentUid: 0],
                        latestMessage: nil
                    )
                    // 사용자 정보 불러와 userInfo에 추가
                    self?.memberUserInfo(uid: opponentUid) {
                        // 없을경우 신규 채팅
                        completionHandler(newChatRoom, true)
                    }
                }
        }
    }
}

extension Notification.Name {
    static let newMessageCountDidChange = Notification.Name("newMessageCountDidChange")
}
