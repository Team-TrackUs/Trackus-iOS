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
        
        LoginCheck()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
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

    // MARK: - 이전 로그인 여부 확인
    func LoginCheck() {
//        self.window?.rootViewController = SplashView()
//        self.window?.makeKeyAndVisible()
        
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            // 리스너 등록 해제
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user == nil {
                self.login()
            } else {
                DispatchQueue.main.async {
                    UserDataManager.shared.getUserData(uid: user?.uid) { newUser in
                        print("사용자 정보 불러오기 시작")
                        if newUser {
                            self.signUp()
                        } else {
                            self.startApp()
                        }
                    }
                }
            }
        })
    }
    
    /// 메인 화면
    private func startApp() {
        self.window?.rootViewController = CustomTabBarVC()
        self.window?.makeKeyAndVisible()
    }
    
    private func login() {
        self.window?.rootViewController = LoginVC()
        self.window?.makeKeyAndVisible()
    }
    /// 회원가입 화면
    private func signUp() {
        self.window?.rootViewController = SignUpVC()
        self.window?.makeKeyAndVisible()
    }
}

