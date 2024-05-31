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
        return mapview
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
    
    var ownerUid: String = ""
    
    let buttonStack = UIStackView()
    
    lazy var preMapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(goCourseDetail(_:)))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
        runningStyleColor()
        
        print("DEBUG: OwnerUid = \(ownerUid)")
    }
    
    // MARK: - Selectors
    
    @objc func goCourseDetail(_ sender: UITapGestureRecognizer) {
        let courseMapVC = CourseMapVC()
        
        courseMapVC.testcoords = self.courseCoords
        courseMapVC.distanceLabel.text = self.distanceLabel.text
        
        self.navigationController?.pushViewController(courseMapVC, animated: true)
    }
    
    @objc func courseEnterButtonTapped() {
        PostService().enterPost(postUid: postUid, userUid: uid, members: members) { updateMembers in
            self.members = updateMembers
        }
    }
    
    @objc func courseExitButtonTapped() {
        
        if ownerUid == uid {
            PostService().deletePost(postUid: self.postUid, imageUrl: self.imageUrl) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            PostService().exitPost(postUid: postUid, userUid: uid, members: members) { updateMembers in
                self.members = updateMembers
            }
        }
    }
    
    @objc func goChatRoomButtonTapped() {
        
        if members.contains(uid) {
            // 채팅방에 참여 했을 시 -> 해당 모집글 톡방
            
        } else {
            // 채팅방에 참여 하지 않았을 경우 -> 방장 개인톡
            
        }
        
    }
    
    @objc func menuButtonTapped() {
        let editAction = UIAlertAction(title: "모집글 수정", style: .default) { action in
            
        }
        
        let reportAction = UIAlertAction(title: "모집글 신고", style: .destructive) { action in
            
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if ownerUid == uid {
            // 작성자인 경우
            alert.addAction(editAction)
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
        buttonContainer.addSubview(divider)
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        buttonContainer.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
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
        
        MapConfigureUI()
        
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
        if members.contains(uid) {
            buttonStack.addArrangedSubview(courseExitButton)
            buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            buttonStack.addArrangedSubview(goChatRoomButton)
            goChatRoomButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
            goChatRoomButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
            
            if ownerUid == uid {
                courseExitButton.backgroundColor = .caution
                courseExitButton.setTitle("글 삭제하기", for: .normal)
            } else {
                courseExitButton.backgroundColor = .caution
                courseExitButton.setTitle("트랙 나가기", for: .normal)
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
        
        buttonContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor, constant: 16).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor, constant: -16).isActive = true
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
            
            if ownerUid == uid {
                courseExitButton.backgroundColor = .caution
                courseExitButton.setTitle("글 삭제하기", for: .normal)
            } else {
                courseExitButton.backgroundColor = .caution
                courseExitButton.setTitle("트랙 나가기", for: .normal)
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
}

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
    
}

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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if courseCoords.count > 0 {
            if !isRegionSet {
                
                guard let region = courseCoords.makeRegionToFit() else { return }
                preMapView.setRegion(region, animated: true) // 위치를 코스의 시작위치로
                
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


/*
 
 "4명의 TrackUs 회원이 이 러닝 모임에 참여중입니다!"
 참여한 사람의 이미지와 이름 Cell을 만들기
 
 */
