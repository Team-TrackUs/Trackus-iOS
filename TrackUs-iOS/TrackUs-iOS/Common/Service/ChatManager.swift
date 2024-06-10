//
//  ChatManager.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/30/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoomManager {
    static let shared = ChatRoomManager()
    
    var chatRooms: [Chat] = []
    var userInfo: [String: User] = [:]
    
    
    
    private let ref = Firestore.firestore().collection("chats")
    
    // MARK: - 채팅방 리스너 관련
    // 채팅방 listener 추가
    func subscribeToUpdates(completionHandler: @escaping () -> Void) {
        let currentUid = User.currentUid
        ref.whereField("members.\(currentUid)", isEqualTo: true).addSnapshotListener() { [weak self] (snapshot, _) in
            self?.storeChatRooms(snapshot, currentUid)
            completionHandler()
        }
    }
    
    // 채팅방 Firebase 정보 가져오기
    private func storeChatRooms(_ snapshot: QuerySnapshot?, _ currentUId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.chatRooms = snapshot?.documents
                .compactMap { [weak self] document in
                    do {
                        let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                        return self?.makeChatRooms(firestoreChatRoom, currentUId)
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
        }
    }
    
    // ChatRoom타입에 맞게 변환
    private func makeChatRooms(_ firestoreChatRoom: FirestoreChatRoom, _ currentUId: String) -> Chat {
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
    
    // 채팅방 멤버 닉네임, 프로필사진url 불러오기
    private func memberUserInfo(uid: String) {
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                // 탈퇴 사용자인 경우 리스트에서 삭제
                self.chatRooms = self.chatRooms.map{
                    var chatRoom = $0
                    chatRoom.members = $0.members.filter{ $0.key != uid }
                    return chatRoom
                }
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
    
}
