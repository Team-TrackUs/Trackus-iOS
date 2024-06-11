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
        title = "User List"
        setupTableView()
        fetchUsers()
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
        let db = Firestore.firestore()
        db.collection("users").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                //print("Error getting users: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.users = documents.compactMap { document in
                let data = document.data()
                var user = User()
                user.name = data["name"] as? String ?? ""
                user.profileImageUrl = data["profileImageUrl"] as? String
                self.userIds.append(document.documentID)
                return user
            }
            self.tableView.reloadData()
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
}
