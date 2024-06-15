//
//  RunningMateVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class RunningMateVC: UIViewController {
    
    // MARK: - Properties
    private let pageSize: Int = 10
    private var lastDocumentSnapshot: DocumentSnapshot?
    private var posts = [Post]()
    private var isLoadingMore = false
    private var isPagingComplete = false
    let refreshView = RefreshView()
    
    private var deletedPostUIDs = [String]()
    
    private lazy var refreshControl : UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        control.tintColor = UIColor.clear
        control.attributedTitle = NSAttributedString(string: "모집글 새로고침", attributes: [.foregroundColor: UIColor.clear])
        
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsSelection = true
        tableView.register(MateViewCell.self, forCellReuseIdentifier: MateViewCell.identifier)
        return tableView
    }()
    
    private lazy var moveButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "plus_icon"), for: .normal)
        btn.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 40 / 2
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor.gray2.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withTintColor(.gray2, renderingMode: .alwaysOriginal))
    
    let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "검색어를 입력해주세요"
        label.textColor = UIColor.gray2
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let footer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150)
        return view
    }()
    
    let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "마지막 모집글을 확인했어요"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.gray1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var footerButton: UIButton = {
        let button = UIButton()
        button.setTitle("새로고침", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = .mainBlue
        button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var navigationMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .gray1
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchPosts()
    }
    
    // MARK: - Selectors
    
    @objc func moveButtonTapped() {
        HapticManager.shared.hapticImpact(style: .light)
        let courseRegisterVC = CourseRegisterVC()
        let navController = UINavigationController(rootViewController: courseRegisterVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func searchButtonTapped() {
        let searchVC = SearchVC()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func footerButtonTapped() {
        fetchPosts()
        
        // 스크롤 맨 위로 이동하도록
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
    }
    
    @objc func refreshPosts() {
        
        HapticManager.shared.hapticImpact(style: .light)
        fetchPosts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
        refreshView.updateText()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        
        self.view.addSubview(searchButton)
        searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        searchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        searchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        searchButton.addSubview(searchIcon)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor).isActive = true
        searchIcon.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor, constant: -16).isActive = true
        
        searchButton.addSubview(searchLabel)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchLabel.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor).isActive = true
        searchLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: 16).isActive = true
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.backgroundView = refreshView
        
        tableView.tableFooterView = footer
        tableView.refreshControl = refreshControl
        
        self.view.addSubview(moveButton)
        moveButton.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -17).isActive = true
        moveButton.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -16).isActive = true
        moveButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        moveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        footer.addSubview(footerLabel)
        footerLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
        footerLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: 32).isActive = true
        
        footer.addSubview(footerButton)
        footerButton.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
        footerButton.topAnchor.constraint(equalTo: footerLabel.bottomAnchor, constant: 16).isActive = true
        footerButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        footerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "메이트 모집"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func fetchPosts() {
        let postService = PostService()
        
        postService.fetchPostTable(startAfter: nil, limit: pageSize) { [weak self] resultPosts, lastDocumentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Error fetching posts = \(error.localizedDescription)")
                self.refreshControl.endRefreshing()
                return
            }
            
            if let resultPosts = resultPosts {
                self.posts = resultPosts.filter { post in
                    !self.deletedPostUIDs.contains(post.uid)
                }
                
                self.lastDocumentSnapshot = lastDocumentSnapshot
                self.posts.sort { $0.createdAt > $1.createdAt }
                self.tableView.reloadData()
                self.isPagingComplete = false
            } else {
                print("DEBUG: No posts found")
                self.refreshControl.endRefreshing()
            }
        }
    }
    private func fetchMorePosts() {
        guard !isPagingComplete && !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        
        let postService = PostService()
        
        postService.fetchPostTable(startAfter: lastDocumentSnapshot, limit: pageSize) { [weak self] resultPosts, lastDocumentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Error fetching posts = \(error.localizedDescription)")
                self.isLoadingMore = false
                return
            }
            
            if let resultPosts = resultPosts {
                if resultPosts.isEmpty {
                    self.isPagingComplete = true
                }
                
                let newPosts = resultPosts.filter { post in
                    !self.posts.contains(where: { $0.uid == post.uid })
                }
                
                self.posts.append(contentsOf: newPosts)
                self.lastDocumentSnapshot = lastDocumentSnapshot
                self.posts.sort { $0.createdAt > $1.createdAt }
                self.tableView.reloadData()
            } else {
                print("DEBUG: No posts found")
            }
            self.isLoadingMore = false
        }
    }
}

extension RunningMateVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as? MateViewCell else {
            fatalError("The tableView could not dequeue a MateViewCell in ViewController")
        }
        
        let post = posts[indexPath.row]
        cell.configure(post: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let courseDetailVC = CourseDetailVC(isBack: true)
        courseDetailVC.hidesBottomBarWhenPushed = true
        
        courseDetailVC.postUid = post.uid
        
        navigationMenuButton.addTarget(courseDetailVC, action: #selector(courseDetailVC.menuButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: navigationMenuButton)
        courseDetailVC.navigationItem.rightBarButtonItem = barButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: courseDetailVC, action: #selector(courseDetailVC.backButtonTapped))
        backButton.tintColor = .black
        courseDetailVC.navigationItem.leftBarButtonItem = backButton
        
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // 인피니티 스크롤 (무한 스크롤)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        
        if offsetY > contentHeight - 100 && !isLoadingMore && !isPagingComplete {
            fetchMorePosts()
        }
    }
}

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
