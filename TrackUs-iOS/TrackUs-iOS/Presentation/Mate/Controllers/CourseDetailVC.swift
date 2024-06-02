//
//  CourseDetailVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/17/24.
//

import UIKit
import MapKit

class CourseDetailVC: UIViewController {
    
    // MARK: - Properties
    
    let uid = User.currentUid // 사용자의 UID
    var postUid: String = ""
    var imageUrl: String = ""
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let collectionView: UICollectionView = { // 참여인원
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(MatePeopleListCell.self, forCellWithReuseIdentifier: MatePeopleListCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var courseCoords: [CLLocationCoordinate2D] = [] // 코스
    var members: [String] = [] {
        didSet {
            // members 데이터에 변화가 있으면 해당하는 뷰 업데이트
            updateView()
        }
    }
    var memberLimit: Int = 0 // 최대 인원
    var distance: Double = 0.0 // 거리
    
    lazy var mapImageButton: UIButton = { // 코스 지도 이미지
        let button = UIButton()
        button.setImage(UIImage(named: ""), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .mainBlue
        button.addTarget(self, action: #selector(goCourseDetail), for: .touchUpInside)
        return button
    }()
    
    let distanceLabel: UILabel = { // 코스 거리
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = .mainBlue
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 20
        label.textAlignment = .center
        return label
    }()
    
    let dateLabel: UILabel = { // 코스 날짜
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    let runningStyleLabel: UILabel = { // 러닝스타일
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.backgroundColor = .mainBlue
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
    }()
    
    let courseTitleLabel: UILabel = { // 코스 제목
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    let courseLocationLabel: UILabel = { // 코스 장소
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    let locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "locationPin_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.2, 0.9, 0.9)
        return imageView
    }()
    
    let courseTimeLabel: UILabel = { // 코스 시간
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray2
        return label
    }()
    
    let timeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "time_icon"))
        imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        return imageView
    }()
    
    let courseDestriptionLabel: UILabel = { // 코스 소개글
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray1
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var courseEnterButton: UIButton = { // 트랙 참여 버튼
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 56 / 2
        
        button.addTarget(self, action: #selector(courseEnterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var courseExitButton: UIButton = { // 트랙 나가기 버튼
        let button = UIButton(type: .system)
        button.backgroundColor = .mainBlue
        button.setTitle("트랙 나가기", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 56 / 2
        
        button.addTarget(self, action: #selector(courseExitButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var goChatRoomButton: UIButton = { // 채팅방 이동 버튼
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "chatBubble_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        button.addTarget(self, action: #selector(goChatRoomButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let personInLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .mainBlue
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray1
        label.text = "의 TrackUs 회원이 이 러닝 모임에 참여중입니다!"
        return label
    }()
    
    private lazy var navigationMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    let buttonStack = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
        runningStyleColor()
    }
    
    // MARK: - Selectors
    
    @objc func goCourseDetail() {
        print("DEBUG: 지도클릭")
        let courseMapVC = CourseMapVC()
        
        courseMapVC.testcoords = self.courseCoords
        courseMapVC.distanceLabel.text = self.distanceLabel.text
        
        self.navigationController?.pushViewController(courseMapVC, animated: true)
    }
    
    @objc func courseEnterButtonTapped() {
        print("DEBUG: 참가하기 클릭")
        
        PostService().enterPost(postUid: postUid, userUid: uid, members: members) { updateMembers in
            self.members = updateMembers
        }
    }
    
    @objc func courseExitButtonTapped() {
        print("DEBUG: 나가기 클릭")
        
        PostService().exitPost(postUid: postUid, userUid: uid, members: members) { updateMembers in
            self.members = updateMembers
        }
    }
    
    @objc func goChatRoomButtonTapped() {
        print("DEBUG: 채팅 버튼 클릭")
        
    }
    
    @objc func menuButtonTapped() {
        print("DEBUG: 네비게이션 버튼 클릭")
        
        let editAction = UIAlertAction(title: "모집글 수정", style: .default) { action in
            
        }
        
        let deleteAction = UIAlertAction(title: "모집글 삭제", style: .destructive) { action in
            
            PostService().deletePost(postUid: self.postUid, imageUrl: self.imageUrl) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        let reportAction = UIAlertAction(title: "모집글 신고", style: .destructive) { action in
            
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if members[0] == uid {
            // 참여인원의 0번째(작성자)라면
            alert.addAction(editAction)
            alert.addAction(deleteAction)
        } else {
            alert.addAction(reportAction)
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(buttonContainer)
        view.addSubview(scrollView)
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        buttonContainer.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor)
        ])
        
        scrollView.addSubview(mapImageButton)
        mapImageButton.translatesAutoresizingMaskIntoConstraints = false
        mapImageButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        mapImageButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        mapImageButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        mapImageButton.heightAnchor.constraint(equalToConstant: 310).isActive = true
        mapImageButton.contentHorizontalAlignment = .fill
        mapImageButton.contentVerticalAlignment = .fill
        
        mapImageButton.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: mapImageButton.leftAnchor, constant: 16).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: mapImageButton.bottomAnchor, constant: -30).isActive = true
        distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        scrollView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: mapImageButton.bottomAnchor, constant: 16).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: mapImageButton.bottomAnchor, constant: 16).isActive = true
        runningStyleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        runningStyleLabel.widthAnchor.constraint(equalToConstant: 54).isActive = true
        runningStyleLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        let stackView = UIStackView()
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(courseTitleLabel)
        courseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        courseTitleLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16).isActive = true
        
        let locationTimeStack = UIStackView(arrangedSubviews: [locationIcon, courseLocationLabel, timeIcon, courseTimeLabel])
        locationTimeStack.axis = .horizontal
        locationTimeStack.spacing = 5
        
        stackView.addArrangedSubview(locationTimeStack)
        locationTimeStack.translatesAutoresizingMaskIntoConstraints = false
        locationTimeStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
        
        let spacer = UIView()
        locationTimeStack.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(courseDestriptionLabel)
        courseDestriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        courseDestriptionLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16).isActive = true
        courseDestriptionLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16).isActive = true
        
        let spacer2 = UIView()
        let personInStack = UIStackView(arrangedSubviews: [personInLabel, textLabel, spacer2])
        personInStack.axis = .horizontal
        personInStack.spacing = 0
        
        stackView.addArrangedSubview(personInStack)
        personInStack.translatesAutoresizingMaskIntoConstraints = false
        personInStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
        
        stackView.addArrangedSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fill // dldl
        
        // 해당 유저가 참여했는지 안했는지
        
        if members.contains(uid) {
            buttonStack.addArrangedSubview(courseExitButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            buttonStack.addArrangedSubview(goChatRoomButton)
            goChatRoomButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
            goChatRoomButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        } else {
            buttonStack.addArrangedSubview(courseEnterButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            if members.count >= memberLimit {
                courseEnterButton.backgroundColor = .systemGray
                courseEnterButton.setTitle("모집 마감", for: .normal)
                courseEnterButton.isEnabled = false
            } else {
                courseEnterButton.backgroundColor = .mainBlue
                courseEnterButton.setTitle("트랙 참여하기", for: .normal)
                courseEnterButton.isEnabled = true
            }
        }
        
        buttonContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor).isActive = true
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "모집글 상세보기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let barButton = UIBarButtonItem(customView: navigationMenuButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func runningStyleColor() {
        switch runningStyleLabel.text {
        case "걷기":
            self.runningStyleLabel.backgroundColor = .walking
        case "조깅":
            self.runningStyleLabel.backgroundColor = .jogging
        case "달리기":
            self.runningStyleLabel.backgroundColor = .running
        case "인터벌":
            self.runningStyleLabel.backgroundColor = .interval
        default:
            self.runningStyleLabel.backgroundColor = .mainBlue
        }
    }
    
    func updateView() {
        
        self.collectionView.reloadData()
        self.personInLabel.text = "\(members.count)명"
        
        buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if members.contains(uid) {
            buttonStack.addArrangedSubview(courseExitButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            buttonStack.addArrangedSubview(goChatRoomButton)
            goChatRoomButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
            goChatRoomButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        } else {
            buttonStack.addArrangedSubview(courseEnterButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            if members.count >= memberLimit {
                courseEnterButton.backgroundColor = .systemGray
                courseEnterButton.setTitle("모집 마감", for: .normal)
                courseEnterButton.isEnabled = false
            } else {
                courseEnterButton.backgroundColor = .mainBlue
                courseEnterButton.setTitle("트랙 참여하기", for: .normal)
                courseEnterButton.isEnabled = true
            }
        }
    }
}

extension CourseDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatePeopleListCell.identifier, for: indexPath) as? MatePeopleListCell else {
            fatalError("Unable to dequeue MatePeopleListCell")
        }
        cell.configure(image: UIImage(named: "profile_img") ?? UIImage(imageLiteralResourceName: "profile_img"), name: "TrackUs")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let itemWidth = collectionView.bounds.height
        return UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
    }
    
}


/*
 
 "4명의 TrackUs 회원이 이 러닝 모임에 참여중입니다!"
 참여한 사람의 이미지와 이름 Cell을 만들기
 
 */
