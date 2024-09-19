//
//  CustomTabBarVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import CoreMotion

final class CustomTabBarVC: UITabBarController {
    
    private let pedometer = CMPedometer()
    lazy var mainButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        btn.backgroundColor = .mainBlue
        btn.setTitle("RUN!", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.layer.cornerRadius = 18
        btn.layer.shadowPath = UIBezierPath(roundedRect: btn.bounds, cornerRadius: btn.layer.cornerRadius).cgPath
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 3, height: 3)
        btn.layer.shadowOpacity = 0.4
        btn.addTarget(self, action: #selector(goToRunTrackingVC), for: .touchUpInside)
        return btn
    }()
    
    private let mainBtnWidth: CGFloat = 48
    
    let networkCheck = NetworkService()
    let networkErrorView = NetworkErrorView(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(networkErrorView)
        networkErrorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        networkErrorView.frame.origin.y = -networkErrorView.frame.height
        networkErrorView.translatesAutoresizingMaskIntoConstraints = false
        networkErrorView.isHidden = true
        
        // 네트워크 체크 시작
        networkCheck.startCheckingNetwork()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatBadge), name: .newMessageCountDidChange, object: nil)
    }
    
    override func loadView() {
        super.loadView()
        addTabItems()
        setupMainButton()
        updateChatBadge()
        networkCheck.startCheckingNetwork()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .newMessageCountDidChange, object: nil)
    }
    
    func setupMainButton() {
        self.tabBar.addSubview(mainButton)
        mainButton.frame = CGRect(x: (Int(self.tabBar.bounds.width) / 2) - (Int(mainBtnWidth) / 2), y: -18, width: 48, height: 48)
    }
    
    func addTabItems() {
        let homeVC = UINavigationController(rootViewController: RunningHomeVC())
        let mateVC = UINavigationController(rootViewController: RunningMateVC())
        let chatVC = UINavigationController(rootViewController: ChatListVC())
        let profileVC = UINavigationController(rootViewController: MyProfileVC())
        
        homeVC.title = "러닝맵"
        mateVC.title = "모집"
        chatVC.title = "채팅"
        profileVC.title = "프로필"
        
        self.setViewControllers([homeVC, mateVC, chatVC, profileVC], animated: false)
        self.modalPresentationStyle = .fullScreen
        self.tabBar.backgroundColor = .systemBackground
        
        guard let items = self.tabBar.items else { return }
        items[0].image = UIImage(systemName: "mappin.and.ellipse")
        
        items[1].image = UIImage(resource: .mateTabbarIcon)
        items[1].titlePositionAdjustment = UIOffset(horizontal: -CGFloat(mainBtnWidth / 2), vertical: 0)
        
        items[2].image = UIImage(resource: .chattingTabbarIcon)
        items[2].titlePositionAdjustment = UIOffset(horizontal: CGFloat(mainBtnWidth / 2), vertical: 0)
        items[3].image = UIImage(resource: .profileTabbarIcon)
    }
    
    @objc func goToRunTrackingVC() {
        CoreMotionService.shared.checkAuthrization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                let viewController = UINavigationController(rootViewController: RunTrackingVC())
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: false)
            } else if status == .denied {
                self.showAuthorizationAlert()
            }
        }
    }
    
    @objc func handleNetworkStatusChange(_ notification: Notification) {
        if let userInfo = notification.userInfo, let isConnected = userInfo["isConnected"] as? Bool {
            DispatchQueue.main.async {
                if isConnected {
                    self.networkErrorView.isHidden = true
                    UIView.animate(withDuration: 0.3) {
                        self.networkErrorView.frame.origin.y = -self.networkErrorView.frame.height
                    }
                } else {
                    self.networkErrorView.isHidden = false
                    UIView.animate(withDuration: 0.3) {
                        self.networkErrorView.frame.origin.y = 64
                    }
                }
            }
        }
    }
    
    func showAuthorizationAlert() {
        let alert = UIAlertController(title: "권한", message: "설정에서 동작 및 피트니스 권한을 설정 해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "설정하러 가기", style: .default, handler: goToAppSettings))
        
        self.present(alert, animated: true)
    }
    
    
    private func goToAppSettings(_ sender: UIAlertAction) {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    // 채팅 뱃지 갯수 업데이트
    @objc func updateChatBadge() {
        guard let items = self.tabBar.items else { return }
        
        let chatBadgeCount = ChatManager.shared.newMessageCount
        items[2].badgeValue = chatBadgeCount
    }
}
