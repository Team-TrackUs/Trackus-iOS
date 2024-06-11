//
//  SideMenuVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/10/24.
//

import UIKit

class SideMenuVC: UIViewController {
    
    private let chat: Chat
    private let userInfo = ChatRoomManager.shared.userInfo
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: SideMenuDelegate?
    
    private let menuWidth: CGFloat = 300
    private var menuView: UIView!
    private var dimmedView: UIView!
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        if chat.group{
            titleLabel.text = chat.title
        } else {
            titleLabel.text = (userInfo[chat.nonSelfMembers[0]]?.name ?? "") + "님과 채팅"
        }
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private lazy var countLabel: UILabel = {
        let countLabel = UILabel()
        if chat.group{
            countLabel.text = String(chat.nonSelfMembers.count + 1)
            countLabel.isHidden = false
        } else {
            countLabel.isHidden = true
        }
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        countLabel.textColor = .gray2
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        return countLabel
    }()
    
    private lazy var membersLabel: UILabel = {
        let membersLabel = UILabel()
        membersLabel.text = "채팅방 맴버"
        membersLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        membersLabel.textColor = .gray2
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        return membersLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDimmedView()
        setupMenuView()
        setupSwipeGesture()
        setupTapGesture()
    }
    
    /// 배경 여백 부분
    private func setupDimmedView() {
        dimmedView = UIView(frame: view.bounds)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
    }
    
    private func setupMenuView() {
        menuView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: menuWidth, height: view.bounds.height))
        menuView.backgroundColor = .systemBackground
        view.addSubview(menuView)
        menuView.addSubview(titleLabel)
        menuView.addSubview(countLabel)
        menuView.addSubview(membersLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: menuView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            membersLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            membersLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
        ])
        
        // Add members profiles
        var previousMemberView: UIView = membersLabel
        
        // 본인 정보 출력
        var myInfo = UserManager.shared.user
        myInfo.name += " (나)"
        let memberView = createMemberView(member: myInfo)
        menuView.addSubview(memberView)
        
        NSLayoutConstraint.activate([
            memberView.topAnchor.constraint(equalTo: previousMemberView.bottomAnchor, constant: 8),
            memberView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16)
        ])
        previousMemberView = memberView
        
        // 나머지 멤버 출력
        for member in chat.nonSelfMembers {
            guard let member = userInfo[member] else { return }
            let memberView = createMemberView(member: member)
            menuView.addSubview(memberView)
            
            NSLayoutConstraint.activate([
                memberView.topAnchor.constraint(equalTo: previousMemberView.bottomAnchor, constant: 8),
                memberView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16)
            ])
            previousMemberView = memberView
        }
        
        let leaveButton = UIButton()
        leaveButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.forward"), for: .normal)
        leaveButton.tintColor = .gray
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.addTarget(self, action: #selector(leaveChatRoom), for: .touchUpInside)
        
        menuView.addSubview(leaveButton)
        
        NSLayoutConstraint.activate([
            leaveButton.bottomAnchor.constraint(equalTo: menuView.safeAreaLayoutGuide.bottomAnchor),
            leaveButton.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16)
        ])
    }
    
    // 사용자 목록 view 만들기
    private func createMemberView(member: User) -> UIView {
        let memberView = UIView()
        memberView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        // Assume `Member` has a method to load image from URL
        profileImageView.loadProfileImage(url: member.profileImageUrl)
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        let nameLabel = UILabel()
        nameLabel.text = member.name
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        memberView.addSubview(profileImageView)
        memberView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: memberView.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: memberView.topAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: memberView.bottomAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: memberView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: memberView.trailingAnchor)
        ])
        
        return memberView
    }
    
    // 오른쪽 스와이프 제스쳐
    private func setupSwipeGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .right
        menuView.addGestureRecognizer(swipeGesture)
    }
    
    // 배경 탭 제스쳐
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        hideMenu()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        hideMenu()
    }
    
    @objc private func leaveChatRoom() {
        delegate?.didSelectLeaveChatRoom(chatRoomID: chat.uid)
        hideMenu()
    }
    
    // 메뉴 보이기 애니메이션
    func showMenu() {
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 1
            self.menuView.frame.origin.x = self.view.bounds.width - self.menuWidth
        }
    }
    
    // 메뉴 끄기 애니메이션
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 0
            self.menuView.frame.origin.x = self.view.bounds.width
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

protocol SideMenuDelegate {
    func didSelectLeaveChatRoom(chatRoomID: String)
}
