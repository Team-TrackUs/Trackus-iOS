//
//  SceneDelegate.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import FirebaseAuth
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
        window = UIWindow(windowScene: windowScene)
        // 스플래시 화면 표시
        window?.rootViewController = SplashView()
        window?.makeKeyAndVisible()
        // 로그인 여부 확인
        loginCheck()
        if let notificationResponse = connectionOptions.notificationResponse {
            let userInfo = notificationResponse.notification.request.content.userInfo
            if let chatUid = userInfo["chatUid"] as? String {
                showChatRoom(chatUid: chatUid)
            }
        }
    }
    
    // Kakao 로그인 관련
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - 로그인 여부 확인 관련 함수 목록
    
    // 로그인 여부 확인
    func loginCheck() {
        // Firebase 인증 상태 리스너 등록
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            if let user = user {
                // Firestore에서 사용자 정보 확인
                checkUserInFirestore(uid: user.uid)
                // 로그인이 확인되었으므로 리스너 해제
                //Auth.auth().removeStateDidChangeListener(authListener!)
            } else {
                // 로그인하지 않은 경우 로그인 화면으로 전환
                self.showLoginView()
            }
        }
    }
    
    // 사용자 정보 유무 조건 확인
    func checkUserInFirestore(uid: String) {
        // 로그인 사용자 기본 정보 유무 확인
        UserManager.shared.checkUserData(uid: uid) { userFound in
            DispatchQueue.main.async {
                if userFound {
                    // 메인 화면으로 전환
                    self.showMainView()
                } else {
                    // 회원가입 화면으로 전환
                    self.showSignUpView()
                }
            }
        }
    }
    
    /// 메인 화면
    func showLoginView() {
        DispatchQueue.main.async {
            self.window?.rootViewController = LoginVC()
        }
    }
    // 회원가입 화면
    func showSignUpView() {
        DispatchQueue.main.async {
            self.window?.rootViewController = SignUpVC()
        }
    }
    // 메인 화면
    func showMainView() {
        DispatchQueue.main.async {
            self.window?.rootViewController = CustomTabBarVC()
        }
    }
    
    // MARK: - Notification관련 view 이동
    func showChatRoom(chatUid: String) {
        guard let rootViewController = window?.rootViewController as? UINavigationController else {
            return
        }
        
        let chatRoomVC = ChatRoomVC(chatUId: chatUid)
        rootViewController.pushViewController(chatRoomVC, animated: true)
    }
}

