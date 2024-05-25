//
//  RunningMateVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/11/24.
//

import UIKit
import CoreLocation

class RunningMateVC: UIViewController {
    
    // MARK: - Properties
    
    private var posts = [Post]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
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
        btn.backgroundColor = .white
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
        
        Task {
            await fetchPosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        Task {
            await fetchPosts()
        }
    }
    
    // MARK: - Selectors
    
    @objc func moveButtonTapped() {
        let mateDetailVC = CourseRegisterVC()
        mateDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(mateDetailVC, animated: true)
        
    }
    
    @objc func searchButtonTapped() {
        print("DEBUG: 검색 버튼 클릭")
        let searchVC = SearchVC()
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
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
        
        self.view.addSubview(moveButton)
        moveButton.bottomAnchor.constraint(equalTo: tableView.bottomAnchor,constant: -17).isActive = true
        moveButton.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -16).isActive = true
        moveButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        moveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "메이트 모집"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func fetchPosts() async {
        print("DEBUG: Fetching posts...")
        
        let postService = PostService()
        
        do {
            print("DEBUG: Trying to fetch posts from Firestore...")
            
            // fetchPost 함수 호출 및 완료까지 대기
            try await postService.fetchPost()
            
            print("DEBUG: Posts fetched successfully.")
            
            // fetchPost 함수가 완료된 후에 posts 배열 업데이트
            self.posts = postService.posts
            print("DEBUG: 포스트 = \(posts)")
            
            // 데이터를 가져온 후 호출
            tableView.reloadData()
        } catch {
            print("DEBUG: Error fetching posts - \(error.localizedDescription)")
            
            let nsError = error as NSError
            print("DEBUG: Firestore error - Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.localizedDescription)")
        }
    }
    
    func runningStyleString(for runningStyle: Int) -> String {
        switch runningStyle {
        case 0:
            return "걷기"
        case 1:
            return "조깅"
        case 2:
            return "달리기"
        case 3:
            return "인터벌"
        default:
            return "걷기"
        }
    }
}

extension RunningMateVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MateViewCell.identifier, for: indexPath) as? MateViewCell else {
            fatalError("The tableView could not dequeue a MateViewCell in ViewController")
        }
        
        let post = posts[indexPath.row]
        cell.configure(image: UIImage(named: "profile_img") ?? UIImage(imageLiteralResourceName: "profile_img"), runningStyleLabel: runningStyleString(for: post.runningStyle), titleLabel: post.title, locationLabel: post.address, timeLabel: post.startDate.toString(format: "h:mm a"), distanceLabel: "\(String(format: "%.2f", post.distance))km", peopleLimit: post.numberOfPeoples, peopleIn: post.members.count, dateLabel: post.startDate.toString(format: "yyyy년 MM월 dd일"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let courseDetailVC = CourseDetailVC()
        courseDetailVC.hidesBottomBarWhenPushed = true
        
        courseDetailVC.courseCoords = post.courseRoutes.map { geoPoint in
            
            return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        }
        courseDetailVC.courseTitleLabel.text = post.title
        courseDetailVC.courseDestriptionLabel.text = post.content
        courseDetailVC.distanceLabel.text = "\(String(format: "%.2f", post.distance))km"
        courseDetailVC.dateLabel.text = post.startDate.toString(format: "yyyy.MM.dd")
        courseDetailVC.runningStyleLabel.text = runningStyleString(for: post.runningStyle)
        courseDetailVC.courseLocationLabel.text = post.address
        courseDetailVC.courseTimeLabel.text = post.startDate.toString(format: "h:mm a")
        courseDetailVC.personInLabel.text = "\(post.members.count)명"
        courseDetailVC.members = post.members
        courseDetailVC.postUid = post.uid
        
        
        self.navigationController?.pushViewController(courseDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
