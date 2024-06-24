//
//  AppDelegate.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let nativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: nativeAppKey as! String)
        
        // push 포그라운드 설정
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        // 메세지 델리게이트
        Messaging.messaging().delegate = self
        // 현재 등록 토큰 가져오기
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        return true
    }
    
    // kakao 로그인 url 세션
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
    
    // fcm 토큰 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let semaphore = DispatchSemaphore(value: 0)
                Task.detached
                {
                    if #available(iOS 16.2, *) {
                        await WidgetManager.shared.activity.end(nil, dismissalPolicy: .immediate)
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - token: \(String(describing: fcmToken))")
        // FCM 토큰 저장
        UserManager.shared.updateToken(token: fcmToken)
    }
}

// MARK: - 알림 델리게이트
extension AppDelegate : UNUserNotificationCenterDelegate {
    // 앱이 켜져있을때 푸시메세지 받아올때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        guard let chatUid = userInfo["chatUid"] as? String else { return }
        // 현재 열려있는 채팅방이 아닐 경우에만 Notification 알림
        if chatUid != ChatManager.shared.currentChatUid {
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    // 푸시메세지 받을때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        //var bestAttemptContent = response.notification.request.content.mutableCopy() as? UNMutableNotificationContent        //신규추가
        NotificationCenter.default.post(
                    name: Notification.Name("didReceiveRemoteNotification"),
                    object: nil,
                    userInfo: userInfo
                )
        // badge 숫자 추가
        UIApplication.shared.applicationIconBadgeNumber +=  1
        
        // notification tap 했을때 실행
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            guard let chatUid = userInfo["chatUid"] as? String else { return }
            let rootView = UIApplication.getMostTopViewController()
            let chatRoomVC = ChatRoomVC(chatUId: chatUid)
            chatRoomVC.hidesBottomBarWhenPushed = true
            rootView?.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
        completionHandler()
    }
}
