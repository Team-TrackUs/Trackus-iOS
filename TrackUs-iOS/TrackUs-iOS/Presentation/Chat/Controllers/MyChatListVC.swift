//
//  MyChatListVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit

class MyChatListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chat = ChatRoomManager.shared
    
    private lazy var chatListTableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: "ChatRoomCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 72
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //chat.dummyData()
        chat.subscribeToUpdates(){
            DispatchQueue.main.async {
                self.chatListTableView.reloadData()
            }
        }
        setupNavBar()
        view.backgroundColor = .systemBackground
        chatListTableView.delegate = self
        setupAutoLayout()
    }

    private func setupNavBar() {
        self.navigationItem.title = "채팅 목록"
        self.navigationItem.titleView?.tintColor = .label
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
        self.view.addSubview(chatListTableView)
        
        NSLayoutConstraint.activate([
            chatListTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            chatListTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            chatListTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            chatListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    // MARK: - view 관련 함수
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if chatViewModel.chatRooms.count == 0 {
//            let label = UILabel(frame: tableView.bounds)
//            label.text = "참여한 채팅방이 없습니다"
//            label.textAlignment = .center
//            label.textColor = .gray
//            tableView.backgroundView = label
//            return 0
//        } else {
//            tableView.backgroundView = nil
//            return chatViewModel.chatRooms.count
//        }
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomCell
        let chatRoom = chat.chatRooms[indexPath.row]
        cell.configure(with: chatRoom, users: chat.userInfo)
        return cell
    }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let chatRoomVC = ChatRoomVC(chat: chat.chatRooms[indexPath.row])
            navigationController?.pushViewController(chatRoomVC, animated: true)
        }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "나가기") { (action, view, completionHandler) in
            // 나가기 함수 추가
            
            completionHandler(true)
        }
//        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chat.chatRooms.count == 0 {
            let label = UILabel(frame: tableView.bounds)
            label.text = "참여한 채팅방이 없습니다"
            label.textAlignment = .center
            label.textColor = .gray3
            tableView.backgroundView = label
            return 0
        } else {
            tableView.backgroundView = nil
            return chat.chatRooms.count
        }
        //return chat.chatRooms.count
    }
}
