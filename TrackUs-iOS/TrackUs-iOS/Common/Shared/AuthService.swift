//
//  AuthService.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/14/24.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import CryptoKit
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

final class AuthService: NSObject {
    static let shared = AuthService()
    
    private override init () {}
    
    
    var window: UIWindow?
    fileprivate var currentNonce: String?
    
    // MARK: - 회원관리
    /// 로그아웃
    func logOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
        }
    }
    
    /// 회원탈퇴
    
    
    /// 닉네임 중복 확인
    func checkUser(name: String, completionHandler: @escaping (Bool) -> Void) async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("users")
                .whereField("name", isEqualTo: name).getDocuments()
            if querySnapshot.isEmpty {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        } catch {
            completionHandler(true)
        }
    }
    
    /// 사용자 정보 -> 이미지 URL 반환 (String?)
    func saveUserData(user: User, image: UIImage?) {
        // 이미지 저장 -> url 포함 User 저장
        guard let image = image else { return self.storeUserInformation(user: user) }
        let uid = User.currentUid
        let ref = Storage.storage().reference().child("profileImages/\(uid)")
        
        // 이미지 비율 줄이기 (용량 감소 목적)
        guard let resizedImage = image.resizeWithWidth(width: 300) else { return }
        // 이미지 포멧 JPEG 변경
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 storage에 저장
        ref.putData(jpegData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to push image to Storage: \(error)")
                return
            }
            // url 받아오기
            ref.downloadURL { url, error in
                if let error = error{
                    print("Failed to retrieve downloadURL: \(error)")
                    return
                }
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                
                // 이미지 url 저장
                guard let url = url else { return }
                var user = user
                user.uid = uid
                user.profileImageUrl = url.absoluteString
                ImageCacheManager.shared.setImage(image: image, url: url.absoluteString)
                self.storeUserInformation(user: user)
                return
            }
        }
    }
    
    /// 사용자 정보 저장
    private func storeUserInformation(user: User) {
        let uid = User.currentUid
        // 해당부분 자료형 지정 필요
        let userData = ["uid": User.currentUid,
                        "name": user.name,
                        "isProfilePublic": user.isProfilePublic,
                        "profileImageUrl": user.profileImageUrl as Any,
                        "isBlock": user.isBlock as Any,
                        "token": user.token] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).setData(userData){ error in
            if error != nil {
                return
            }
            print("success")
        }
    }
    
    // MARK: - apple 로그인
    func handleAppleLogin() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // Apple Login 필요 함수
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension AuthService: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            
            Task {
                do {
                    _ = try await Auth.auth().signIn(with: credential)
                }
                catch {
                    print("Error authenticating: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window ?? UIWindow()
    }
}


// MARK: - Kakao 로그인
extension AuthService {
    
    func handleKakaoLogin() {
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            kakaoLoginInApp()
        } else {
            // 카카오톡이 설치 안됐을 경우
            kakaoLoginInWeb()
        }
    }
    
    // 카카오톡 앱에서 로그인
    private func kakaoLoginInApp() {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                //oauthToken.
                print("카카오톡 로그인 성공")
                
                //do something
                if let _ = oauthToken {
                    self.loginInFirebase()
                }
            }
        }
    }
    
    // 카카오톡 앱이 없는 경우 웹 로그인
    private func kakaoLoginInWeb() {

        UserApi.shared.loginWithKakaoAccount { oauthToken, error in
            if let error = error {
                print("DEBUG: 카카오톡 로그인 에러 \(error.localizedDescription)")
            } else {
                print("카카오톡 로그인 성공")
                if let _ = oauthToken {
                    self.loginInFirebase()
                }
            }
        }
    }
    
    // 파이어베이스 로그인, 회원가입
    private func loginInFirebase() {

        UserApi.shared.me() { user, error in
            if let error = error {
                print("error: 카카오톡 사용자 정보가져오기 에러 \(error.localizedDescription)")
            } else {
                print("카카오톡 사용자 정보 가져오기 성공.")

                guard let user = user else { return }
                // 파이어베이스 유저 생성 (이메일로 회원가입)
                Auth.auth().createUser(withEmail: (user.kakaoAccount?.email)!, password: "\(String(describing: user.id))") { result, error in
                    if let error = error {
                        print("error: 파이어베이스 사용자 생성 실패 \(error.localizedDescription)")
                        Auth.auth().signIn(withEmail: (user.kakaoAccount?.email)!,
                                           password: "\(String(describing: user.id))")
                    } else {
                        print("카카오 파이어베이스 사용자 생성")
                    }
                }
            }
        }
    }
}
