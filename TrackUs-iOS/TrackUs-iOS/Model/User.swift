//
//  User.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/14/24.
//

import Foundation
import Firebase

struct User: Codable{
    // 임시 테스트 용
//    var id = ""
//    var username: String
//    var email: String
//    var pushId = ""
//    var avatarLink = ""
//    var status: String
    
    // 이후 모델
    //var uid: String
    var name: String
    var profileImageUrl: String?
    var isProfilePublic: Bool

    /// FCM 전송 토큰
    var token: String
    
    /// 차단한 사용자 리스트
    var blockedUserList: [String]?
    var blockingMeList: [String]?
    /// 필터링용도 List : 본인이 차단한 사용자 + 본인을 차단한 사용자 리스트
    var blockList: [String] {
        var result: [String] = []
        if let blockedUserList = blockedUserList{
            result += blockedUserList
        }
        if let blockingMeList = blockingMeList {
            result += blockingMeList
        }
        return result
    }
    
    /// 미처리된 신고 uid 리스트 -> 사용자 임시 필터링 용도
    var reportIDList: [String]?
    
    /// 앱 이용 차단 여부
    var isBlock: Bool = false
    
    
    static var currentUid: String {
        return Auth.auth().currentUser!.uid
    }
    
//    static var currentUser: User? {
//        if Auth.auth().currentUser != nil {
//            if let dictionary = UserDefaults.standard.data(forKey: "currentUser") {
//                
//                let decoder = JSONDecoder()
//                
//                do {
//                    let object = try decoder.decode(User.self, from: dictionary)
//                    return object
//                } catch {
//                    print("Error decoding user", error.localizedDescription)
//                }
//            }
//        }
//        
//        return nil
//    }
    
//    static func == (lhs: User, rhs: User) -> Bool {
//        lhs.uid == rhs.uid
//    }
}
