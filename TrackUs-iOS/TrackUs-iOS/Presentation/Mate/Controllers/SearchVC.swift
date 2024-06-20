//
//  SearchVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/20/24.
//

import UIKit
import CoreLocation

class SearchVC: UIViewController, UITextFieldDelegate {

    // MARK: - Properties

    private let searchController = UISearchController()

    private var posts = [Post]()
    private var searchResultsPosts = [Post]()

    private lazy var searchBar: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력해주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.backgroundColor = .white
        textField.frame = CGRect(x: 0, y: 0, width: 300, height: 48)
        
        // 검색창 설정
        textField.returnKeyType = .search
        textField.inputAccessoryView = toolBarKeyboard
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        
        return textField
    }()

    private lazy var toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "검색", style: .done, target: self, action: #selector(btnDoneBarTapped))
        toolbar.sizeToFit()
        toolbar.items = [flexBarButton, doneButton]
        toolbar.tintColor = .mainBlue
        return toolbar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(MateViewCell.self, forCellReuseIdentifier: MateViewCell.identifier)
        return tableView
    }()
    
    private lazy var navigationMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dots_icon"), for: .normal)
        button.tintColor = .black
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let searchText = searchBar.text, !searchText.isEmpty {
            searchPosts(for: searchText)
        }
        tableView.reloadData()
    }

    // MARK: - Selectors

    @objc func btnDoneBarTapped(sender: Any) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            print("DEBUG: Search text is nil or empty")
            return
        }
        searchPosts(for: searchText)
    }

    // MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func setupNavBar() {
        self.navigationItem.title = "검색"
        self.navigationItem.titleView = searchBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func searchPosts(for searchText: String) {
        let postService = PostService()
        postService.searchFilter(searchText: searchText) { [weak self] filteredPosts in
            self?.searchResultsPosts = filteredPosts
            self?.tableView.reloadData()
        }
    }
    
    // 키보드 리턴키
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            print("DEBUG: Search text is nil or empty")
            return true
        }
        searchPosts(for: searchText)
        return true
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as? MateViewCell else {
            fatalError("The tableView could not dequeue a MateViewCell in ViewController")
        }

        let post = searchResultsPosts[indexPath.row]

        cell.configure(post: post)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = searchResultsPosts[indexPath.row]

        let courseDetailVC = CourseDetailVC(isBack: true)
        courseDetailVC.hidesBottomBarWhenPushed = true

        courseDetailVC.postUid = post.uid
        
        navigationMenuButton.addTarget(courseDetailVC, action: #selector(courseDetailVC.menuButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: navigationMenuButton)
        courseDetailVC.navigationItem.rightBarButtonItem = barButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: courseDetailVC, action: #selector(courseDetailVC.backButtonTapped))
        backButton.tintColor = .black
        courseDetailVC.navigationItem.leftBarButtonItem = backButton

        self.searchBar.resignFirstResponder()
        self.navigationController?.pushViewController(courseDetailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: false)
    }
}
