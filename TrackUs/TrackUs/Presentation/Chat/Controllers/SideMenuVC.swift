//
//  SideMenuVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/10/24.
//

import UIKit

protocol SideMenuDelegate {
    func didSelectLeaveChatRoom(chatRoomID: String)
}

class SideMenuVC: UIViewController {
    
    private let chat: Chat
    private let userInfo = ChatManager.shared.userInfo
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: SideMenuDelegate?
    var profileImageDelegate: UserCellDelegate?
    
    private let menuWidth: CGFloat = 300
    private var menuView: UIView!
    private var dimmedView: UIView!
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        if chat.group {
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
        if chat.group {
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
    
    private lazy var membersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MemberCell.self, forCellReuseIdentifier: "MemberCell")
        tableView.tableFooterView = UIView()
        return tableView
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
        menuView.addSubview(membersTableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: menuView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            membersLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            membersLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            
            membersTableView.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 8),
            membersTableView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            membersTableView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            membersTableView.bottomAnchor.constraint(equalTo: menuView.bottomAnchor)
        ])
        
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

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.nonSelfMembers.count + 1 // 본인 포함
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            // 본인 정보
            var myInfo = UserManager.shared.user
            myInfo.name += " (나)"
            cell.configure(with: myInfo)
        } else {
            let memberUid = chat.nonSelfMembers[indexPath.row - 1]
            if let memberInfo = userInfo[memberUid] {
                cell.configure(with: memberInfo)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var uid: String
        if indexPath.row == 0 {
            // 본인 정보
            uid = UserManager.shared.user.uid
        } else {
            uid = chat.nonSelfMembers[indexPath.row - 1]
        }
        
        profileImageDelegate?.didTapProfileImage(for: uid)
        hideMenu()
    }
}
