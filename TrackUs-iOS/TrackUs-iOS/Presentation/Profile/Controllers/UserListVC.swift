//
//  UserListVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 6/3/24.
//

import UIKit
import Firebase

class UserListVC: UIViewController {
    
    private var users: [User] = []
    private var userIds: [String] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupTableView()
        fetchUsers()
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "차단된 계정"
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
    }
    
    private func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else { return }
            
            if let blockedUserList = document.data()?["blockedUserList"] as? [String] {
                if blockedUserList.isEmpty {
                    self.showNoBlockedUsersMessage()
                } else {
                    db.collection("users").whereField(FieldPath.documentID(), in: blockedUserList).getDocuments { (snapshot, error) in
                        guard let snapshot = snapshot, error == nil else {
                            return
                        }
                        
                        self.users = snapshot.documents.compactMap { document in
                            var user = User()
                            let data = document.data()
                            user.name = data["name"] as? String ?? ""
                            user.profileImageUrl = data["profileImageUrl"] as? String
                            self.userIds.append(document.documentID)
                            return user
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                self.showNoBlockedUsersMessage()
            }
        }
    }
    
    private func showNoBlockedUsersMessage() {
        let messageLabel = UILabel()
        messageLabel.text = "차단된 사용자가 없습니다."
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.font = UIFont.systemFont(ofSize: 20)
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    private func unblockUser(at index: Int) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let blockedUserId = userIds[index]
        
        db.collection("users").document(currentUserId).updateData([
            "blockedUserList": FieldValue.arrayRemove([blockedUserId])
        ]) { error in
            if let error = error {
            } else {
                self.users.remove(at: index)
                self.userIds.remove(at: index)
                if self.users.isEmpty {
                    self.showNoBlockedUsersMessage()
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
extension UserListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUserId = userIds[indexPath.row]
        let otherProfileVC = OtherProfileVC(userId: selectedUserId)
        navigationController?.pushViewController(otherProfileVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.users.removeAll()
        self.userIds.removeAll()
        tableView.reloadData()
        fetchUsers()
    }
}
