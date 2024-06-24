//
//  CourseDetailVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/17/24.
//

import UIKit
import MapKit
import FirebaseFirestore

class CourseDetailVC: UIViewController {
    
    // MARK: - Properties
    
    let uid = User.currentUid // 사용자의 UID
    var postUid: String = ""
    var imageUrl: String = ""
    
    var isRegionSet = false // mapkit
    var locationManager = CLLocationManager() // mapkit
    var pinAnnotations: [MKPointAnnotation] = [] // mapkit
    
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
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
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
    
    var preMapView: MKMapView = { // 지도 미리보기
        let mapview = MKMapView()
        mapview.layer.cornerRadius = 10
        return mapview
    }()
    
    let distanceLabel: UILabel = { // 코스 거리
        let label = UILabel()
        label.textColor = .white
        if let descriptor = UIFont.systemFont(ofSize: 16, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }
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
    
    var ownerUid: String = ""
    
    let buttonStack = UIStackView()
    
    lazy var preMapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(goCourseDetail(_:)))
    
    let skeletonView = MateDetailSkeletonView()
    
    var fetchComplete = false
    var mapUIComplete = false
    var viewUIComplete = false
    
    var isBack: Bool
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skeletonView.isHidden = false
        
        setupNavBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        backGesture()
        
        fetchPostDetail()
        runningStyleColor()
        
        configureUI()
        setupLongGestureRecognizerOnCollection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureUI()
        fetchPostDetail()
        runningStyleColor()
        MapConfigureUI()
        
        if fetchComplete && mapUIComplete && viewUIComplete {
            self.hideSkeletonViewWithFadeIn()
        }
    }
    
    init(isBack: Bool) {
        self.isBack = isBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func goCourseDetail(_ sender: UITapGestureRecognizer) {
        let courseMapVC = CourseMapVC()
        
        courseMapVC.testcoords = self.courseCoords
        courseMapVC.distanceLabel.text = self.distanceLabel.text
        
        self.navigationController?.pushViewController(courseMapVC, animated: true)
    }
    
    @objc func courseEnterButtonTapped() {
        let userManager = UserManager.shared
        let userUid = User.currentUid
        userManager.getUserData(uid: userUid)
        let user = userManager.user
        
        let message = """
        자세한 내용은
        마이페이지 > 설정 > 문의하기
        에서 문의해주시기 바랍니다.
        """
        
        if user.isBlock {
            showAlert(title: "이용이 제한되었습니다.", message: message, action: "제한")
        } else {
            PostService().enterPost(postUid: postUid, userUid: uid, members: members) { updatedMembers, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    
                    self.showAlert(title: "", message: "해당 모집글에 인원이 다 찼습니다.", action: "참여")
                } else if let updatedMembers = updatedMembers {
                    self.members = updatedMembers
                    self.joinRunningChat()
                }
            }
        }
        
    }
    
    func joinRunningChat() {
        // 채팅방 참여
        if ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == postUid }) == nil {
            // 채팅방이 없을 때만 실행
            joinChat(){ [self] in
                if let chat = ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == postUid }){
                    // 기존 채팅방 띄우기
                    joinMessage(chat: chat)
                }
            }
            return
        }
    }
    
    @objc func courseExitButtonTapped() {
        PostService().exitPost(postUid: postUid, userUid: uid, members: members) { updateMembers in
            self.members = updateMembers
        }
    }
    
    @objc func goChatRoomButtonTapped() {
        let message = """
        자세한 내용은
        마이페이지 > 설정 > 문의하기
        에서 문의해주시기 바랍니다.
        """
        if UserManager.shared.user.isBlock {
            showAlert(title: "이용이 제한되었습니다.", message: message, action: "제한")
        } else {
            if members.contains(uid){
                // 채팅방 참여된 경우
                if let chat = ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == postUid }){
                    // 기존 채팅방 띄우기
                    presentChatView(chat: chat)
                }else {
                    // 채팅방 참여하기
                    DispatchQueue.main.async {
                        self.joinChat(){ [self] in
                            if let chat = ChatManager.shared.chatRooms.first(where: { chatRoom in chatRoom.uid == postUid }){
                                // 기존 채팅방 띄우기
                                joinMessage(chat: chat)
                                presentChatView(chat: chat, newChat: true)
                            }
                        }
                    }
                    
                }
            }else {
                // 참여 안된 경우 - 방장 1:1 대화하기
                ChatManager.shared.joinChatRoom(opponentUid: ownerUid) { chat, newChat in
                    let chatRoomVC = ChatRoomVC(chat: chat, newChat: newChat)
                    self.navigationController?.pushViewController(chatRoomVC, animated: true)
                }
            }
        }
    }
    
    @objc func menuButtonTapped() {
        let editAction = UIAlertAction(title: "모집글 수정", style: .default) { action in
            
            let courseRegisterVC = CourseRegisterVC()
            
            courseRegisterVC.testcoords = self.courseCoords
            courseRegisterVC.courseTitle.text = self.courseTitleLabel.text!
            courseRegisterVC.courseTitleString = self.courseTitleLabel.text!
            courseRegisterVC.courseDescription.text = self.courseDestriptionLabel.text!
            courseRegisterVC.courseDescriptionString = self.courseDestriptionLabel.text!
            courseRegisterVC.members = self.members
            courseRegisterVC.personnel = self.memberLimit
            courseRegisterVC.distance = self.distance
            courseRegisterVC.postUid = self.postUid
            courseRegisterVC.isEdit = true
            courseRegisterVC.imageUrl = self.imageUrl
            
            let navController = UINavigationController(rootViewController: courseRegisterVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            
            // DispatchQueue?
            self.navigationController?.popToRootViewController(animated: false)
        }
        
        let deleteAction = UIAlertAction(title: "모집글 삭제", style: .destructive) { action in
            self.showAlert(title: "", message: "모집글을 삭제하시겠습니까?", action: "삭제")
        }
        
        let reportAction = UIAlertAction(title: "모집글 신고", style: .destructive) { action in
            let reportPostVC = ReportPostVC()
            reportPostVC.configure(uid: self.postUid, imageUrl: self.imageUrl, title: self.courseTitleLabel.text ?? "제목 없음", userUid: self.uid)
            self.navigationController?.pushViewController(reportPostVC, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if ownerUid == uid {
            // 작성자인 경우
            alert.addAction(editAction)
            alert.addAction(deleteAction)
        } else {
            alert.addAction(reportAction)
        }
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        
        let isOwner = ownerUid == uid
        
        guard isOwner else { return }
        
        let p = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: p) {
            LongPressCollectionCell(indexPath.row)
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(buttonContainer)
        view.addSubview(scrollView)
        buttonContainer.addSubview(divider)
        
        view.addSubview(skeletonView)
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        skeletonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        skeletonView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        skeletonView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        skeletonView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        buttonContainer.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        divider.topAnchor.constraint(equalTo: buttonContainer.topAnchor).isActive = true
        divider.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor)
        ])
        
        scrollView.addSubview(preMapView)
        preMapView.translatesAutoresizingMaskIntoConstraints = false
        preMapView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16).isActive = true
        preMapView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        preMapView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        preMapView.heightAnchor.constraint(equalToConstant: 310).isActive = true
        preMapView.addGestureRecognizer(preMapViewTapGesture)
        
        preMapView.addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: preMapView.leftAnchor, constant: 16).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: preMapView.bottomAnchor, constant: -30).isActive = true
        distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        scrollView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: preMapView.bottomAnchor, constant: 16).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: preMapView.bottomAnchor, constant: 16).isActive = true
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
        updateView()
        
        buttonContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor, constant: 16).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: -2).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor, constant: -16).isActive = true
        
        viewUIComplete = true
    }
    
    private func setupNavBar() {
        self.navigationItem.title = "모집글 상세보기"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
            
            courseExitButton.setTitle("트랙 나가기", for: .normal)
            
            if ownerUid == uid {
                courseExitButton.backgroundColor = .systemGray
                courseExitButton.isEnabled = false
            } else {
                courseExitButton.backgroundColor = .caution
                courseExitButton.isEnabled = true
            }
        } else {
            buttonStack.addArrangedSubview(courseEnterButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            buttonStack.addArrangedSubview(goChatRoomButton)
            goChatRoomButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
            goChatRoomButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
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
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressedGesture)
    }
    
    private func LongPressCollectionCell(_ user: Int) {
        let action = UIAlertAction(title: "내보내기", style: .destructive) { action in
            
            if self.members[user] == self.uid {
                self.showAlert(title: "오류", message: "방장은 내보낼 수 없습니다.", action: "제한")
                return
            }
            
            PostService().kickUser(postUid: self.postUid, userUid: self.members[user]) { updateMembers, error in
                if error != nil {
                    // 에러 alert
                    self.showAlert(title: "오류", message: "오류가 발생했습니다.", action: "제한")
                } else {
                    self.members = updateMembers ?? self.members
                }
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - 채팅 관련 함수
    func joinChat(completionHandler: @escaping () -> Void) {
        // 채팅방 참여
        let ref = Firestore.firestore().collection("chats")
        ref.document(postUid).updateData([
            "members.\(uid)": true
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        ref.document(postUid).updateData([
            "usersUnreadCountInfo.\(uid)": 0
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
            completionHandler()
        }
    }
    
    private func joinMessage(chat: Chat) {
        let db = Firestore.firestore().collection("chats")
        // 나가기 안내 메세지
        let newMessage = Message(sendMember: uid, timeStamp: Date(), messageType: .userInout, data: true)
        
        // 그룹 채팅방만 해당
        if chat.group {
            // 그룹 메세지 - 각 사용자별 메세지 저장소에 저장
            _ = chat.members.map{
                // 참여중인 사용자 확인
                if $0.value == true {
                    // 해당 사용자 메세지 정보에 저장
                    let db = db.document(chat.uid).collection($0.key)
                    sendMessageFireStore(db: db, message: newMessage)
                }
            }
        }
    }
    
    // 메세지 전송
    private func sendMessageFireStore(db: CollectionReference, message: Message) {
        db.addDocument(data: [
            "sendMember": message.sendMember,
            "timeStamp": message.timeStamp,
            "text": message.text as Any,
            "imageUrl": message.imageUrl as Any,
            "location": message.location as Any,
            "userInOut": message.userInOut as Any
        ]) { error in
            if let error = error {
                print("Error adding message: \(error)")
            }
        }
    }
    
    func fetchPostDetail() {
        PostService().fetchPost(uid: postUid) { post, error in
            
            if let error = error {
                print("DEBUG: Error FetchPostDetail")
                self.showAlert(title: "오류", message: "모집글을 불러오지 못했습니다.", action: "상태")
                return
            }
            
            guard let post = post else {
                self.showAlert(title: "", message: "삭제된 모집글입니다.", action: "상태")
                return
            }
            
            self.courseCoords = post.courseRoutes.map { geoPoint in
                
                return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            self.searchAddress { address in
                self.courseTitleLabel.text = post.title
                self.courseDestriptionLabel.text = post.content
                self.distance = post.distance
                self.distanceLabel.text = "\(String(format: "%.2f", self.distance)) km"
                self.dateLabel.text = post.startDate.toString(format: "yyyy.MM.dd")
                self.runningStyleLabel.text = self.runningStyleString(for: post.runningStyle)
                self.courseLocationLabel.text = address
                self.courseTimeLabel.text = post.startDate.toString(format: "h:mm a")
                self.personInLabel.text = "\(String(describing: post.members.count))명"
                self.members = post.members
                self.memberLimit = post.numberOfPeoples
                self.imageUrl = post.routeImageUrl
                self.ownerUid = post.ownerUid
            }
        }
        fetchComplete = true
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
    
    func showAlert(title: String, message: String, action: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        switch action {
        case "상태":
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            
        case "참여":
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.fetchPostDetail()
            }
            alertController.addAction(okAction)
            
        case "삭제":
            let okAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                PostService().deletePost(postUid: self.postUid, imageUrl: self.imageUrl) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
        case "제한":
            let okAction = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(okAction)
            
        default:
            break
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func searchAddress(completion: @escaping (String) -> Void) {
        let addLoc = CLLocation(latitude: courseCoords[0].latitude, longitude: courseCoords[0].longitude)
        var address = ""
        
        CLGeocoder().reverseGeocodeLocation(addLoc, completionHandler: { place, error in
            if let pm = place?.first {
                if let administrativeArea = pm.administrativeArea {
                    address += administrativeArea
                }
                if let subLocality = pm.subLocality {
                    address += " " + subLocality
                }
            } else {
                print("DEBUG: 주소 검색 실패 \(error?.localizedDescription ?? "Unknown error")")
            }
            completion(address)
        })
    }
    
    private func hideSkeletonViewWithFadeIn() {
        UIView.animate(withDuration: 0.2, animations: {
            self.skeletonView.alpha = 0.0
        }) { _ in
            self.skeletonView.isHidden = true
        }
    }
    
    /// 채팅방 띄우기
    private func presentChatView(chat: Chat, newChat: Bool = false){
        let chatRoomVC = ChatRoomVC(chatUId: chat.uid, newChat: newChat)
        chatRoomVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatRoomVC, animated: true)
    }
}

// MARK: - CollectionViewSetting

extension CourseDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatePeopleListCell.identifier, for: indexPath) as? MatePeopleListCell else {
            fatalError("Unable to dequeue MatePeopleListCell")
        }
        
        let memberUid = members[indexPath.item]
        let isOwner = ownerUid == memberUid
        cell.configure(uid: memberUid, isOwner: isOwner)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MatePeopleListCell else {
            return true
        }
        return !cell.isUnknown
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memberUid = members[indexPath.item]
        let userUid = User.currentUid
        
        if memberUid == userUid {
            // 자신의 프로필은 선택이 안되도록
            return
        } else {
            let otherProfileVC = OtherProfileVC(userId: memberUid)
            let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: otherProfileVC, action: #selector(otherProfileVC.backButtonTapped))
            backButton.tintColor = .black
            otherProfileVC.navigationItem.leftBarButtonItem = backButton
            
            otherProfileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(otherProfileVC, animated: true)
        }
    }
    
}

// MARK: - MapSetting

extension CourseDetailVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    // 맵 세팅
    func MapConfigureUI() {
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        preMapView.delegate = self
        preMapView.mapType = MKMapType.mutedStandard
        preMapView.isZoomEnabled = false
        preMapView.isScrollEnabled = false
        preMapView.showsUserLocation = false
        
        for (index, coord) in courseCoords.enumerated() {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            let pinTitle = "\(index + 1)" // 핀의 제목을 인덱스로 설정
            pin.title = pinTitle
            preMapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
        
        addPolylineToMap()
        
        mapUIComplete = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if courseCoords.count > 0 {
            if !isRegionSet {
                
                guard let region = courseCoords.makeRegionToFit() else { return }
                preMapView.setRegion(region, animated: false) // 위치를 코스의 시작위치로
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.preMapView.setVisibleMapRect(self.preMapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false)
                }
                isRegionSet = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .mainBlue
            testlineRenderer.lineWidth = 5.0
            return testlineRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "pinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        if let pin = annotation as? MKPointAnnotation {
            let label = UILabel(frame: CGRect(x: -8, y: -8, width: 20, height: 20))
            label.text = pin.title ?? "\(courseCoords.count + 1)"
            label.textColor = .mainBlue
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 12)
            
            label.backgroundColor = .white
            label.layer.borderColor = UIColor.mainBlue.cgColor
            label.layer.borderWidth = 2.0
            label.layer.cornerRadius = label.frame.size.width / 2
            
            label.clipsToBounds = true
            annotationView?.addSubview(label)
        }
        
        return annotationView
    }
    
    func addPolylineToMap() {
        let polyline = MKPolyline(coordinates: courseCoords, count: courseCoords.count)
        preMapView.addOverlay(polyline)
    }
}

extension CourseDetailVC: UIGestureRecognizerDelegate {
    // 스와이프로 이전 화면 갈 수 있도록 추가
    func backGesture() {
        if isBack {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
