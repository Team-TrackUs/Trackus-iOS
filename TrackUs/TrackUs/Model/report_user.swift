//
//  report_user.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 6/12/24.
//

import Foundation
import Firebase

struct report_user: Codable {
    var uid: String
    var toUser: String
    var toUserUid: String
    var category: String
    var text: String
    var fromUser: String
    var createdAt: Timestamp

    init(uid: String = UUID().uuidString, toUser: String, toUserUid: String, category: String, text: String, fromUser: String, createdAt: Timestamp = Timestamp()) {
        self.uid = uid
        self.toUser = toUser
        self.toUserUid = toUserUid
        self.category = category
        self.text = text
        self.fromUser = fromUser
        self.createdAt = createdAt
    }
}
