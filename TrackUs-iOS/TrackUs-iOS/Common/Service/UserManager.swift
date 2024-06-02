//
//  UserDataMenager.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/24/24.
//

import Foundation
import Firebase

/// 사용자 본인 데이터 관리
class UserManager {
    static let shared = UserManager()

    var user: User

    private init() {
        self.user = User()
    }
    
    
    // 사용자 정보 불러오기 (리스너 추가) => 신규 사용자 true 반환
    func getUserData(uid: String?, completionHandler: @escaping (Bool) -> Void) {
        guard let uid = uid else { return }
        
        let _ = Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                print("사용자 데이터 불러오기 실패")
                completionHandler(true)
            }else {
                guard let document = documentSnapshot, document.exists, let data = document.data() else {
                    // 사용자 정보 없을 경우
                    completionHandler(true)
                    return
                }
                
                do {
                    // Firestore document data를 JSON으로 변환
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let user = try JSONDecoder().decode(User.self, from: jsonData)
                    // user 데이터 처리
                    DispatchQueue.main.async {
                        self.user = user
                        print(user.uid)
                    }
                    completionHandler(false)
                } catch {
                    print("Error decoding user: \(error)")
                    completionHandler(true)
                }
            }
        }
    }
}
