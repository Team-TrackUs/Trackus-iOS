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
        if group{
            members.filter { $0.value == true && $0.key != User.currentUid }
                .map { $0.key }
                .sorted()
        } else {
            members.filter { $0.key != User.currentUid }.map { $0.key }
        }
    }
    // 메세지 안읽은 갯수
    var usersUnreadCountInfo: [String: Int]
    var latestMessage: LastetMessage?
}

// 최근 메세지
struct LastetMessage {
    var timestamp: Date?
    var text: String?
}

// 메세지 내용
struct Message {
    //let uid: String
    public let sendMember: String
    public let timeStamp: Date
    public let imageUrl: String?
    public let text: String?
    public let location: String?
    public let userInOut: Bool?
    
    public var messageType: MessageType {
        if text != nil {
            return .text
        } else if imageUrl != nil {
            return .image
        } else if location != nil {
            return .location
        } else if userInOut != nil {
            return .userInout
        } else {
            fatalError("Invalid message type")
        }
    }
    /// firestore 변환용
    init(firestoreMessage: FirestoreMessage) {
        self.sendMember = firestoreMessage.sendMember
        self.timeStamp = firestoreMessage.timeStamp
        self.imageUrl = firestoreMessage.imageUrl
        self.text = firestoreMessage.text
        self.location = firestoreMessage.location
        self.userInOut = firestoreMessage.userInOut
    }
    
    //타입 지정 입력
    init(sendMember: String, timeStamp: Date, messageType: MessageType, data: Any) {
        self.sendMember = sendMember
        self.timeStamp = timeStamp
        
        switch messageType {
            case .text:
                self.text = data as? String
                self.imageUrl = nil
                self.location = nil
                self.userInOut = nil
            case .image:
                self.imageUrl = data as? String
                self.text = nil
                self.location = nil
                self.userInOut = nil
            case .location:
                self.location = data as? String
                self.imageUrl = nil
                self.text = nil
                self.userInOut = nil
            case .userInout:
                self.userInOut = data as? Bool
                self.imageUrl = nil
                self.text = nil
                self.location = nil
        }
    }
}

extension Message {
    // 시간 반환
    var time: String {
        DateFormatter.timeFormatter.string(from: timeStamp)
    }
    
    var date: String {
        DateFormatter.dateFormatter.string(from: timeStamp)
    }
}

// 날짜 변환
extension DateFormatter {
    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()
    static let dateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd"

        return formatter
    }()

    static func timeString(_ seconds: Int) -> String {
        let hour = Int(seconds) / 3600
        let minute = Int(seconds) / 60 % 60
        let second = Int(seconds) % 60

        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        }
        return String(format: "%02i:%02i", minute, second)
    }
}

enum MessageType: String, Codable {
    case text
    case image
    case location
    case userInout
}

/// 메세지 맵핑용
struct MessageMap {
    
    let message: Message
    let sameUser: Bool
    let sameDate: Bool
    let sameTime: Bool
    
    init(message: Message, sameUser: Bool, sameDate: Bool, sameTime: Bool) {
        self.message = message
        self.sameUser = sameUser
        self.sameDate = sameDate
        self.sameTime = sameTime
    }
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

// 메세지 내용
struct FirestoreMessage: Codable {
    let sendMember: String
    let timeStamp: Date
    let imageUrl: String?
    let text: String?
    let location: String?
    let userInOut: Bool?
}
