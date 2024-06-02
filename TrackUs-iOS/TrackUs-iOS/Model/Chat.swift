//
//  Chat.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat {
    
    let uid: String
    let group: Bool
    let title: String
    var members: [String: Bool]
    // 본인 제외 사용자 uid -> 채팅 출력 판별용
    var nonSelfMembers: [String] {
        members.filter { $0.value == true && $0.key != User.currentUid }.map { $0.key }
    }
    // 메세지 안읽은 갯수
    var usersUnreadCountInfo: [String: Int]
    var latestMessage: LastetMessage?
    // 개인 채팅 경우에만 사용
    var toUser: String?
    var fromUser: String?
}

// 최근 메세지
struct LastetMessage {
    var timestamp: Date?
    var text: String?
}

// 메세지 내용
struct Message {
    let uid: String
    let timeStamp: Data
    let sendMember: String
    let imageUrl: String?
    let text: String?
    let location: String?
    let userInOut: Bool
}

enum messageType {
    case text
    case image
    case location
    case userInout
}

// MARK: - Firebase 반환용
public struct FirestoreChatRoom: Codable, Hashable {
    @DocumentID public var id: String?
    public let title: String
    public var group: Bool
    public var members: [String: Bool]
    //public var messages: [Message]?
    public var usersUnreadCountInfo: [String: Int]
    public let latestMessage: FirestoreLastMessage?
}

public struct FirestoreLastMessage: Codable, Hashable {

    @DocumentID public var id: String?
    @ServerTimestamp public var timestamp: Date?
    public var text: String
}
