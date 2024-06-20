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
    // 사용자 정보 유무 여부 확인
    func checkUserData(uid: String?, completionHandler: @escaping (Bool) -> Void) {
        guard let uid = uid else {
            completionHandler(false)
            return
        }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [self] documentSnapshot, error in
            if error != nil {
                completionHandler(false)
            } else {
                guard let document = documentSnapshot, document.exists else {
                    // 사용자 정보 없을 경우
                    completionHandler(false)
                    return
                }
                // 사용자 정보 있을경우
                getUserData(uid: uid)
                completionHandler(true)
            }
        }
    }
    
    
    // 사용자 정보 불러오기 (리스너 추가)
    func getUserData(uid: String?) {
        guard let uid = uid else { return }
        
        let _ = Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                print("사용자 데이터 불러오기 실패")
                //completionHandler(true)
            }else {
                guard let document = documentSnapshot, document.exists, let data = document.data() else {
                    // 사용자 정보 없을 경우
                    //completionHandler(true)
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
                    //completionHandler(false)
                } catch {
                    print("Error decoding user: \(error)")
                    //completionHandler(true)
                }
            }
        }
    }
    
    // 사용자 데이터 업데이트
    func updateUserData(user: User ,completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.updateData([
            "name": user.name,
            "isProfilePublic": user.isProfilePublic,
            "profileImageUrl": user.profileImageUrl as Any
        ]) { error in
            if let error = error {
                print("Error updating user data: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // FCM token 업데이트
    func updateToken(token: String?)  {
        guard let uid = Auth.auth().currentUser?.uid, let token = token else { return }
        
        let data = ["token": token]
        Firestore.firestore().collection("users").document(uid).updateData(data) { error in
            if let error = error {
                // 업데이트 중에 오류가 발생한 경우 처리
                print("Error updating token: \(error.localizedDescription)")
            } else {
                // 업데이트가 성공한 경우 처리
                print("Token updated successfully")
            }
        }
    }
}
