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
        textField.inputAccessoryView = toolBarKeyboard
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()

    private lazy var toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(btnDoneBarTapped))
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.becomeFirstResponder()
        Task {
            await fetchPosts()
        }
    }

    // MARK: - Selectors

    @objc func btnDoneBarTapped(sender: Any) {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else { return }
        filterPosts(for: searchText)
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

    private func fetchPosts() async {

        let postService = PostService()

        do {
            try await postService.fetchPost()
            self.posts = postService.posts
            tableView.reloadData()
        } catch {
            let nsError = error as NSError
            print("DEBUG: Firestore error - Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.localizedDescription)")
        }
    }

    private func filterPosts(for searchText: String) {
        searchResultsPosts = posts.filter { post in
            return post.title.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
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

        cell.configure(image: post.routeImageUrl, runningStyleLabel: RunningMateVC().runningStyleString(for: post.runningStyle), titleLabel: post.title, locationLabel: post.address, timeLabel: post.startDate.toString(format: "h:mm a"), distanceLabel: "\(String(format: "%.2f", post.distance))km", peopleLimit: post.numberOfPeoples, peopleIn: post.members.count, dateLabel: post.startDate.toString(format: "yyyy년 MM월 dd일"))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = searchResultsPosts[indexPath.row]

        let courseDetailVC = CourseDetailVC()
        courseDetailVC.hidesBottomBarWhenPushed = true

        courseDetailVC.courseCoords = post.courseRoutes.map { geoPoint in
            return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        }
        courseDetailVC.courseTitleLabel.text = post.title
        courseDetailVC.courseDestriptionLabel.text = post.content
        courseDetailVC.distanceLabel.text = "\(String(format: "%.2f", post.distance)) km"
        courseDetailVC.dateLabel.text = post.startDate.toString(format: "yyyy.MM.dd")
        courseDetailVC.runningStyleLabel.text = RunningMateVC().runningStyleString(for: post.runningStyle)
        courseDetailVC.courseLocationLabel.text = post.address
        courseDetailVC.courseTimeLabel.text = post.startDate.toString(format: "h:mm a")
        courseDetailVC.personInLabel.text = "\(post.members.count)명"
        courseDetailVC.members = post.members
        courseDetailVC.postUid = post.uid
        courseDetailVC.memberLimit = post.numberOfPeoples
        courseDetailVC.imageUrl = post.routeImageUrl

        // 이미지 추가
        // CourseRegisterVC에서도 해야함
        PostService.downloadImage(urlString: post.routeImageUrl) { image in
            DispatchQueue.main.async {
                courseDetailVC.mapImageButton.setImage(image, for: .normal)
            }
        }

        self.searchBar.resignFirstResponder()
        self.navigationController?.pushViewController(courseDetailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: false)
    }

}
