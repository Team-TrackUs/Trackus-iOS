//
//  CourseRegisterVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/14/24.
//

import UIKit
import MapKit
import Firebase
import FirebaseStorage

class CourseRegisterVC: UIViewController {
    
    // MARK: - Properties
    
    lazy var testcoords: [CLLocationCoordinate2D] = [] { // 좌표배열
        didSet {
            updateAddCourseButtonAppearance()
        }
    }
    lazy var distance: CLLocationDistance = 0 { // 거리
        didSet {
            distanceUpdate()
        }
    }
    var runningStyle: Int = 0 { // 러닝 스타일
        didSet {
            updateStyleButtonAppearance()
        }
    }
    
    var courseTitleString: String = "" { // 코스 제목
        didSet {
            updateAddCourseButtonAppearance()
        }
    }
    
    var courseDescriptionString: String = "" { // 코스 소개글
        didSet {
            updateAddCourseButtonAppearance()
        }
    }
    var selectedDate: Date = Date() // 날짜
    var selectedTime: Date = Date() // 시간
    var personnel: Int = 2 // 최소인원수
    var members: [String] = [] // 참여인원
    var postUid: String = "" // 모집글 Uid
    var isEdit: Bool = false
    var imageUrl: String = ""
    
    var isRegionSet = false // mapkit
    var locationManager = CLLocationManager() // mapkit
    var pinAnnotations: [MKPointAnnotation] = [] // mapkit
    
    private lazy var toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(btnDoneBarTapped))
        toolbar.sizeToFit()
        toolbar.items = [flexBarButton, doneButton]
        toolbar.tintColor = .mainBlue
        return toolbar
    }()
    
    var drawMapView: MKMapView = {
        let mapview = MKMapView()
        return mapview
    }()
    
    private lazy var drawMapButton: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.layer.borderWidth = 1.0
        mapView.layer.borderColor = UIColor.gray.cgColor
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(named: "pencil_icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "코스를 입력해주세요"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        
        mapView.addSubview(overlayView)
        overlayView.addSubview(stack)
        
        overlayView.topAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        
        stack.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drawMapButtonTapped))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }()
    
    private lazy var editMapButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(named: "pencil_icon"), for: .normal)
        button.addTarget(self, action: #selector(editMapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let runningStyleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "러닝스타일"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let courseTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "코스 제목"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let courseDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "코스 소개글"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let datePickerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "날짜 설정"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let timePickerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "모집 시간"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let PeopleSettingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.text = "인원 설정"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var styleWalkButton: UIButton = {
        let button = UIButton()
        button.setTitle("걷기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(walkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleFastWalkButton: UIButton = {
        let button = UIButton()
        button.setTitle("조깅", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(FastwalkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleRuuningButton: UIButton = {
        let button = UIButton()
        button.setTitle("달리기", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(RunningButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleSprintButton: UIButton = {
        let button = UIButton()
        button.setTitle("인터벌", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(sprintButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var courseTitle: UITextField = {
        let title = UITextField()
        title.textColor = .black
        title.font = UIFont.systemFont(ofSize: 16)
        title.attributedPlaceholder = NSAttributedString(string: "저장할 러닝 이름을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        title.backgroundColor = .white
        title.frame = CGRect(x: 0, y: 0, width: 398, height: 48)
        title.layer.cornerRadius = 8
        title.layer.borderWidth = 1.0
        title.layer.borderColor = UIColor.gray2.cgColor
        
        title.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        title.leftViewMode = .always
        
        title.addTarget(self, action: #selector(titleValue), for: .editingChanged)
        
        title.inputAccessoryView = toolBarKeyboard
        
        return title
    }()
    
    lazy var courseDescription: UITextView = {
        let description = UITextView()
        description.textColor = .black
        description.font = UIFont.systemFont(ofSize: 16)
        description.backgroundColor = .white
        description.layer.cornerRadius = 8
        description.layer.borderWidth = 1.0
        description.layer.borderColor = UIColor.gray2.cgColor
        description.textContainerInset = UIEdgeInsets(top: 16, left: 4, bottom: 16, right: 4)
        description.isScrollEnabled = false
        description.inputAccessoryView = toolBarKeyboard
        
        return description
    }()
    
    private let courseDescriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "코스에 대한 자세한 설명을 입력해주세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko-KR")
        picker.minimumDate = Date()
        picker.timeZone = .autoupdatingCurrent
        picker.backgroundColor = .white
        picker.addTarget(self, action: #selector(datePickerValue), for: .valueChanged)
        return picker
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko-KR")
        picker.timeZone = .autoupdatingCurrent
        picker.backgroundColor = .white
        picker.addTarget(self, action: #selector(timePickerValue), for: .valueChanged)
        return picker
    }()
    
    private lazy var personUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: #selector(personUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var personDownButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: #selector(personDown), for: .touchUpInside)
        return button
    }()
    
    private lazy var personnelLabel: UILabel = {
        let label = UILabel()
        label.text = String(personnel)
        return label
    }()
    
    private lazy var addCourseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 56 / 2
        
        return button
    }()
    
    private let addCourseButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .mainBlue
        label.text = "\(String(format: "%.2f", distance)) km"
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 40 / 2
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 6
        label.clipsToBounds = true
        if let descriptor = UIFont.systemFont(ofSize: 16, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        } else {
            label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }
        
        return label
    }()
    
    private let warningText: UILabel = {
        let label = UILabel()
        label.text = "부적절하거나 불쾌감을 줄 수 있는 컨텐츠는 제재를 받을 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray2
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loadingView = LoadingView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        courseDescription.delegate = self
        courseTitle.delegate = self
        setupPlaceholder()
        
        configureUI()
        MapConfigureUI()
        
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        configureUI()
        MapConfigureUI()
        setMapResion()
    }
    
    // MARK: - Selectors
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func walkButtonTapped() {
        runningStyle = 0
    }
    
    @objc func FastwalkButtonTapped() {
        runningStyle = 1
    }
    
    @objc func RunningButtonTapped() {
        runningStyle = 2
    }
    
    @objc func sprintButtonTapped() {
        runningStyle = 3
    }
    
    @objc func personUp() {
        if personnel < 10 {
            personnel += 1
            personnelLabel.text = String(personnel)
        }
    }
    
    @objc func personDown() {
        if personnel > 2 {
            personnel -= 1
            personnelLabel.text = String(personnel)
        }
    }
    
    @objc func addCourseButtonTapped() {
        
        loadingView.isHidden = false
        loadingView.startAnimation()
        
        let userUID = User.currentUid
        let postUID = Firestore.firestore().collection("posts").document().documentID
        
        // date와 time을 하나 합쳐서 업로드
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let selectedDateTime = calendar.date(from: combinedComponents) else {
            return
        }
        
        // 주소 입력
        searchAddress { address in
            
            // Post 인스턴스 생성
            var post = Post(uid: postUID, title: self.courseTitleString, content: self.courseDescriptionString, courseRoutes: self.testcoords.map { location in
                return GeoPoint(latitude: location.latitude, longitude: location.longitude)
            }, distance: self.distance, numberOfPeoples: self.personnel, routeImageUrl: "", startDate: selectedDateTime, address: address, whoReportAt: [], createdAt: Date(), runningStyle: self.runningStyle, members: [userUID], ownerUid: userUID)
            
            // 이미지 업로드 후 Post 업데이트
            self.mapSnapshot(with: self.pinAnnotations, polyline: MKPolyline(coordinates: self.testcoords, count: self.testcoords.count)) { [weak self] image in
                guard let self = self else { return }
                PostService.uploadImage(image: image) { url in
                    if let url = url {
                        post.updateRouteImageUrl(newUrl: url.absoluteString)
                        
                        // Post 업로드
                        PostService().uploadPost(post: post) { error in
                            if let error = error {
                                print("DEBUG: Failed to upload post: \(error.localizedDescription)")
                            } else {
                                DispatchQueue.main.async {
                                    let courseDetailVC = CourseDetailVC(isBack: false)
                                    
                                    courseDetailVC.courseCoords = post.courseRoutes.map { geoPoint in
                                        
                                        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                                    }
                                    courseDetailVC.courseTitleLabel.text = post.title
                                    courseDetailVC.courseDestriptionLabel.text = post.content
                                    courseDetailVC.distanceLabel.text = "\(String(format: "%.2f", post.distance))km"
                                    courseDetailVC.dateLabel.text = post.startDate.toString(format: "yyyy.MM.dd")
                                    courseDetailVC.runningStyleLabel.text = MateViewCell().runningStyleString(for: post.runningStyle)
                                    courseDetailVC.courseLocationLabel.text = post.address
                                    courseDetailVC.courseTimeLabel.text = post.startDate.toString(format: "h:mm a")
                                    courseDetailVC.personInLabel.text = "\(post.members.count)명"
                                    courseDetailVC.members = post.members
                                    courseDetailVC.postUid = post.uid
                                    courseDetailVC.memberLimit = post.numberOfPeoples
                                    courseDetailVC.imageUrl = post.routeImageUrl
                                    courseDetailVC.ownerUid = post.ownerUid
                                    
                                    if let xmark = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) {
                                        let dismissButton = UIBarButtonItem(image: xmark, style: .plain, target: self, action: #selector(self.closeModal))
                                        
                                        dismissButton.tintColor = .gray1
                                        
                                        courseDetailVC.navigationItem.leftBarButtonItem = dismissButton
                                        courseDetailVC.navigationItem.rightBarButtonItems = nil
                                    }
                                    
                                    // 채팅방 등록
                                    self.createGroupChatRoom(trackId: postUID, title: self.courseTitleString, uid: userUID)
                                    // + 소희님 users 컬렉션에 참여 모집글 배열에 해당 포스트 uid append
                                    
                                    self.navigationController?.pushViewController(courseDetailVC, animated: true)
                                    
                                    ImageCacheManager.shared.setImage(image: image, url: post.routeImageUrl)
                                }
                            }
                        }
                    } else {
                        print("DEBUG: Image upload failed")
                    }
                }
            }
        }
    }
    
    @objc func editCourseButtonTapped() {
        loadingView.isHidden = false
        loadingView.startAnimation()
        
        let userUID = User.currentUid
        
        // date와 time을 하나 합쳐서 업로드
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        guard let selectedDateTime = calendar.date(from: combinedComponents) else {
            return
        }
        
        // 주소 입력
        searchAddress { address in
            
            // Post 인스턴스 생성
            var post = Post(uid: self.postUid, title: self.courseTitleString, content: self.courseDescriptionString, courseRoutes: self.testcoords.map { location in
                return GeoPoint(latitude: location.latitude, longitude: location.longitude)
            }, distance: self.distance, numberOfPeoples: self.personnel, routeImageUrl: self.imageUrl, startDate: selectedDateTime, address: address, whoReportAt: [], createdAt: Date(), runningStyle: self.runningStyle, members: self.members, ownerUid: userUID)
            
            // 이미지 삭제
            PostService().deleteImage(imageUrl: self.imageUrl)
            
            // 이미지 업로드 후 Post 업데이트
            self.mapSnapshot(with: self.pinAnnotations, polyline: MKPolyline(coordinates: self.testcoords, count: self.testcoords.count)) { [weak self] image in
                guard let self = self else { return }
                PostService.uploadImage(image: image) { url in
                    if let url = url {
                        post.updateRouteImageUrl(newUrl: url.absoluteString)
                        
                        // Post 업로드
                        PostService().uploadPost(post: post) { error in
                            if let error = error {
                                print("DEBUG: Failed to upload post: \(error.localizedDescription)")
                            } else {
                                DispatchQueue.main.async {
                                    
                                    let courseDetailVC = CourseDetailVC(isBack: false)
                                    courseDetailVC.hidesBottomBarWhenPushed = true
                                    
                                    if let xmark = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) {
                                        let dismissButton = UIBarButtonItem(image: xmark, style: .plain, target: self, action: #selector(self.closeModal))
                                        
                                        dismissButton.tintColor = .gray1
                                        
                                        courseDetailVC.navigationItem.leftBarButtonItem = dismissButton
                                        courseDetailVC.navigationItem.rightBarButtonItems = nil
                                    }
                                    
                                    courseDetailVC.postUid = post.uid
                                    
                                    self.navigationController?.pushViewController(courseDetailVC, animated: true)
                                    
                                    ImageCacheManager.shared.setImage(image: image, url: post.routeImageUrl)
                                }
                            }
                        }
                    } else {
                        print("DEBUG: Image upload failed")
                    }
                }
            }
        }
        createGroupChatRoom(trackId: postUid, title: self.courseTitleString, uid: userUID)
    }
    
    @objc func btnDoneBarTapped(sender: Any) {
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func drawMapButtonTapped() {
        let courseDrawingMapVC = CourseDrawingMapVC()
        courseDrawingMapVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(courseDrawingMapVC, animated: true)
    }
    
    @objc func datePickerValue(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @objc func timePickerValue(_ sender: UIDatePicker) {
        selectedTime = sender.date
    }
    
    @objc func titleValue(_ sender: UITextField) {
        courseTitleString = sender.text ?? ""
    }
    
    @objc func editMapButtonTapped() {
        self.testcoords.removeAll()
        self.distance = 0.0
        
        for annotation in pinAnnotations {
            drawMapView.removeAnnotation(annotation)
        }
        pinAnnotations.removeAll()
        
        if let overlays = drawMapView.overlays as? [MKPolyline] {
            drawMapView.removeOverlays(overlays)
        }
        
        let courseDrawingMapVC = CourseDrawingMapVC()
        courseDrawingMapVC.testcoords = testcoords
        courseDrawingMapVC.distance = distance
        courseDrawingMapVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(courseDrawingMapVC, animated: true)
    }
    
    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(addCourseButtonContainer)
        view.addSubview(scrollView)
        addCourseButtonContainer.addSubview(divider)
        
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loadingView.isHidden = true
        
        addCourseButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        addCourseButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        addCourseButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addCourseButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        addCourseButtonContainer.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        addCourseButtonContainer.addSubview(addCourseButton)
        addCourseButton.translatesAutoresizingMaskIntoConstraints = false
        addCourseButton.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor, constant: 10).isActive = true
        addCourseButton.leftAnchor.constraint(equalTo: addCourseButtonContainer.leftAnchor, constant: 16).isActive = true
        addCourseButton.bottomAnchor.constraint(equalTo: addCourseButtonContainer.bottomAnchor, constant: -2).isActive = true
        addCourseButton.rightAnchor.constraint(equalTo: addCourseButtonContainer.rightAnchor, constant: -16).isActive = true
        addCourseButton.setTitle(isEdit ? "코스 수정하기" : "코스 등록하기", for: .normal)
        addCourseButton.addTarget(self, action: isEdit ? #selector(editCourseButtonTapped) : #selector(addCourseButtonTapped), for: .touchUpInside)
        
        divider.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor).isActive = true
        divider.leadingAnchor.constraint(equalTo: addCourseButtonContainer.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: addCourseButtonContainer.trailingAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        if testcoords.count == 0 {
            scrollView.addSubview(drawMapButton)
            drawMapButton.translatesAutoresizingMaskIntoConstraints = false
            drawMapButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 17).isActive = true
            drawMapButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
            drawMapButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
            drawMapButton.heightAnchor.constraint(equalToConstant: 310).isActive = true
            drawMapButton.widthAnchor.constraint(equalTo: addCourseButton.widthAnchor).isActive = true
            drawMapButton.layer.cornerRadius = 10
            
            scrollView.addSubview(runningStyleLabel)
            runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
            runningStyleLabel.topAnchor.constraint(equalTo: drawMapButton.bottomAnchor, constant: 27).isActive = true
            runningStyleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        } else {
            scrollView.addSubview(drawMapView)
            drawMapView.translatesAutoresizingMaskIntoConstraints = false
            drawMapView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 17).isActive = true
            drawMapView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
            drawMapView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
            drawMapView.heightAnchor.constraint(equalToConstant: 310).isActive = true
            drawMapView.widthAnchor.constraint(equalTo: addCourseButton.widthAnchor).isActive = true
            drawMapView.layer.cornerRadius = 10
            
            drawMapView.addSubview(editMapButton)
            editMapButton.translatesAutoresizingMaskIntoConstraints = false
            editMapButton.trailingAnchor.constraint(equalTo: drawMapView.trailingAnchor, constant: -8).isActive = true
            editMapButton.topAnchor.constraint(equalTo: drawMapView.topAnchor, constant: 8).isActive = true
            
            drawMapView.addSubview(distanceLabel)
            distanceLabel.translatesAutoresizingMaskIntoConstraints = false
            distanceLabel.leadingAnchor.constraint(equalTo: drawMapView.leadingAnchor, constant: 16).isActive = true
            distanceLabel.bottomAnchor.constraint(equalTo: drawMapView.bottomAnchor, constant: -30).isActive = true
            distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
            distanceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            scrollView.addSubview(runningStyleLabel)
            runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
            runningStyleLabel.topAnchor.constraint(equalTo: drawMapView.bottomAnchor, constant: 27).isActive = true
            runningStyleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        }
        
        
        styleWalkButton.widthAnchor.constraint(equalToConstant: 76).isActive = true
        styleWalkButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        styleFastWalkButton.widthAnchor.constraint(equalToConstant: 76).isActive = true
        styleFastWalkButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        styleRuuningButton.widthAnchor.constraint(equalToConstant: 76).isActive = true
        styleRuuningButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        styleSprintButton.widthAnchor.constraint(equalToConstant: 76).isActive = true
        styleSprintButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [styleWalkButton, styleFastWalkButton, styleRuuningButton, styleSprintButton])
        stack.axis = .horizontal
        stack.spacing = 13
        stack.distribution = .fillEqually
        
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        stack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        stack.topAnchor.constraint(equalTo: runningStyleLabel.bottomAnchor, constant: 12).isActive = true
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 13
        
        textStack.addArrangedSubview(courseTitleLabel)
        courseTitle.widthAnchor.constraint(equalToConstant: 398).isActive = true
        courseTitle.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textStack.addArrangedSubview(courseTitle)
        textStack.addArrangedSubview(courseDescriptionLabel)
        courseDescription.widthAnchor.constraint(equalToConstant: 398).isActive = true
        courseDescription.heightAnchor.constraint(equalToConstant: 180).isActive = true
        textStack.addArrangedSubview(courseDescription)
        
        scrollView.addSubview(textStack)
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        textStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        textStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 12).isActive = true
        
        let datePickerStack = UIStackView(arrangedSubviews: [datePickerLabel, datePicker])
        datePickerStack.axis = .horizontal
        datePickerStack.spacing = 100
        
        scrollView.addSubview(datePickerStack)
        datePickerStack.translatesAutoresizingMaskIntoConstraints = false
        datePickerStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        datePickerStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        datePickerStack.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 27).isActive = true
        
        let timePickerStack = UIStackView(arrangedSubviews: [timePickerLabel, timePicker])
        timePickerStack.axis = .horizontal
        timePickerStack.spacing = 100
        
        scrollView.addSubview(timePickerStack)
        timePickerStack.translatesAutoresizingMaskIntoConstraints = false
        timePickerStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        timePickerStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        timePickerStack.topAnchor.constraint(equalTo: datePickerStack.bottomAnchor, constant: 27).isActive = true
        
        let personnelButtonStack = UIStackView(arrangedSubviews: [personDownButton, personnelLabel, personUpButton])
        personnelButtonStack.axis = .horizontal
        personnelButtonStack.spacing = 8
        
        let personnelStack = UIStackView(arrangedSubviews: [PeopleSettingsLabel, personnelButtonStack])
        personnelStack.axis = .horizontal
        personnelStack.spacing = 100
        
        scrollView.addSubview(personnelStack)
        personnelStack.translatesAutoresizingMaskIntoConstraints = false
        personnelStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        personnelStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        personnelStack.topAnchor.constraint(equalTo: timePickerStack.bottomAnchor, constant: 27).isActive = true
        personnelStack.widthAnchor.constraint(equalToConstant: 116).isActive = true
        personnelStack.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        scrollView.addSubview(warningText)
        warningText.topAnchor.constraint(equalTo: personnelStack.bottomAnchor, constant: 27).isActive = true
        warningText.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        warningText.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        warningText.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16).isActive = true
        
        updateStyleButtonAppearance()
        updateAddCourseButtonAppearance()
        
    }
    
    func updateStyleButtonAppearance() {
        styleWalkButton.setTitleColor(runningStyle == 0 ? .white : .gray2, for: .normal)
        styleWalkButton.backgroundColor = runningStyle == 0 ? .walking : .white
        styleWalkButton.layer.borderColor = runningStyle == 0 ? UIColor.walking.cgColor : UIColor.gray2.cgColor
        
        styleFastWalkButton.setTitleColor(runningStyle == 1 ? .white : .gray2, for: .normal)
        styleFastWalkButton.backgroundColor = runningStyle == 1 ? .jogging : .white
        styleFastWalkButton.layer.borderColor = runningStyle == 1 ? UIColor.jogging.cgColor : UIColor.gray2.cgColor
        
        styleRuuningButton.setTitleColor(runningStyle == 2 ? .white : .gray2, for: .normal)
        styleRuuningButton.backgroundColor = runningStyle == 2 ? .running : .white
        styleRuuningButton.layer.borderColor = runningStyle == 2 ? UIColor.running.cgColor : UIColor.gray2.cgColor
        
        styleSprintButton.setTitleColor(runningStyle == 3 ? .white : .gray2, for: .normal)
        styleSprintButton.backgroundColor = runningStyle == 3 ? .interval : .white
        styleSprintButton.layer.borderColor = runningStyle == 3 ? UIColor.interval.cgColor : UIColor.gray2.cgColor
    }
    
    func updateAddCourseButtonAppearance() {
        if testcoords.isEmpty || courseTitleString.isEmpty || courseDescriptionString.isEmpty {
            addCourseButton.backgroundColor = .systemGray
            addCourseButton.isEnabled = false
        } else {
            addCourseButton.backgroundColor = .mainBlue
            addCourseButton.isEnabled = true
        }
    }
    
    func setup(with testCoords: [CLLocationCoordinate2D], distance: CLLocationDistance) {
        self.testcoords = testCoords
        self.distance = distance
    }
    
    // 맵 세팅
    func MapConfigureUI() {
        self.locationManager = CLLocationManager() // 사용자 위치를 가져오는데 필요한 객체
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization() // 앱을 처음 열 때 사용자의 위치를 얻을 수 있는 권한을 팝업으로 요청
        locationManager.startUpdatingLocation()
        drawMapView.delegate = self
        drawMapView.mapType = MKMapType.standard
        drawMapView.isZoomEnabled = true
        drawMapView.isScrollEnabled = true
        drawMapButton.showsUserLocation = true
        drawMapButton.isZoomEnabled = false
        drawMapButton.isScrollEnabled = false
        
        for (index, coord) in testcoords.enumerated() {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            let pinTitle = "\(index + 1)"
            pin.title = pinTitle
            drawMapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
        
        addPolylineToMap()
    }
    
    private func setupNavBar() {
        if isEdit {
            self.navigationItem.title = "모집글 수정"
        } else {
            self.navigationItem.title = "모집글 등록"
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        if let xmark = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) {
            let closeButton = UIBarButtonItem(image: xmark, style: .plain, target: self, action: #selector(closeModal))
            closeButton.tintColor = .gray1
            
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func distanceUpdate() {
        distanceLabel.text = "\(String(format: "%.2f", distance)) km"
    }
    
    // 지도 스냅샷
    func mapSnapshot(with annotations: [MKAnnotation], polyline: MKPolyline, completion: @escaping (UIImage) -> Void) {
        
        let sizeWidth = 300
        let sizeHeight = 300
        
        // 이미지 생성 전 지도에 패딩 넣기
        let options = MKMapSnapshotter.Options()
        let mapRect = polyline.boundingMapRect
        let edgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let paddedMapRect = mapRect.insetBy(dx: -mapRect.size.width * Double(edgePadding.left) / Double(sizeWidth), dy: -mapRect.size.height * Double(edgePadding.top) / Double(sizeHeight))
        let paddedRegion = MKCoordinateRegion(paddedMapRect)
        
        options.region = paddedRegion
        options.size = CGSize(width: sizeWidth, height: sizeHeight)
        options.mapType = .mutedStandard
        options.showsBuildings = false
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            
            let image = snapshot.image
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            
            // Polyline 그리기
            let path = UIBezierPath()
            let points = polyline.points()
            for i in 0..<polyline.pointCount {
                let point = points[i]
                let coordinate = point.coordinate
                let location = snapshot.point(for: coordinate)
                if i == 0 {
                    path.move(to: location)
                } else {
                    path.addLine(to: location)
                }
            }
            UIColor.mainBlue.setStroke()
            path.lineWidth = 7
            path.stroke()
            
            // Annotation 그리기
            for annotation in annotations {
                let location = snapshot.point(for: annotation.coordinate)
                let text = annotation.title ?? "\(self.testcoords.count + 1)"
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 9),
                    .foregroundColor: UIColor.mainBlue
                ]
                
                let attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
                let textSize = attributedText.size()
                
                let circleDiameter = max(textSize.width, textSize.height) // 여백 추가
                let circleRect = CGRect(x: location.x - circleDiameter / 2, y: location.y - circleDiameter / 2, width: circleDiameter, height: circleDiameter)
                
                let context = UIGraphicsGetCurrentContext()
                context?.setFillColor(UIColor.white.cgColor)
                context?.fillEllipse(in: circleRect)
                
                context?.setStrokeColor(UIColor.mainBlue.cgColor)
                context?.setLineWidth(1.0)
                context?.strokeEllipse(in: circleRect)
                
                let textRect = CGRect(x: circleRect.origin.x + (circleRect.width - textSize.width) / 2,
                                      y: circleRect.origin.y + (circleRect.height - textSize.height) / 2,
                                      width: textSize.width, height: textSize.height)
                
                attributedText.draw(in: textRect)
            }
            
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            completion(finalImage ?? UIImage())
        }
    }
    
    func searchAddress(completion: @escaping (String) -> Void) {
        let addLoc = CLLocation(latitude: testcoords[0].latitude, longitude: testcoords[0].longitude)
        var address = ""
        
        CLGeocoder().reverseGeocodeLocation(addLoc, completionHandler: { place, error in
            if let pm = place?.first {
                if let subLocality = pm.subLocality {
                    address += subLocality
                }
            } else {
                print("DEBUG: 주소 검색 실패 \(error?.localizedDescription ?? "Unknown error")")
            }
            completion(address)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setMapResion() {
        guard let region = self.testcoords.makeRegionToFit() else { return }
        self.drawMapView.setRegion(region, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.drawMapView.setVisibleMapRect(self.drawMapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false)
        }
    }
}

// MARK: - MapKit
extension CourseRegisterVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if testcoords.count > 0 {
            if !isRegionSet {
                guard let region = testcoords.makeRegionToFit() else { return }
                drawMapView.setRegion(region, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.drawMapView.setVisibleMapRect(self.drawMapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false)
                }
                isRegionSet = true
            }
        } else {
            var mapRegion = MKCoordinateRegion()
            mapRegion.center = drawMapButton.userLocation.coordinate
            mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            
            drawMapButton.setRegion(mapRegion, animated: true)
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
            label.text = pin.title ?? "\(testcoords.count + 1)"
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
        let polyline = MKPolyline(coordinates: testcoords, count: testcoords.count)
        drawMapView.addOverlay(polyline)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CourseRegisterVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // 그룹 채팅방 생성하기
    func createGroupChatRoom(trackId: String, title: String, uid: String) {
        let newChatRoom: [String: Any] = [
            "title": title,
            "group": true,
            "members": [uid: true],
            "usersUnreadCountInfo": [uid: 0]
            //"latestMessage": nil
        ]  as [String : Any]
        Firestore.firestore().collection("chats").document(trackId).setData(newChatRoom)
    }
}

// MARK: - Keyboard

extension CourseRegisterVC: UITextViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        courseDescription.becomeFirstResponder()
        return true
    }
    
    func setupPlaceholder() {
        courseDescription.addSubview(courseDescriptionPlaceholder)
        courseDescriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        courseDescriptionPlaceholder.topAnchor.constraint(equalTo: courseDescription.topAnchor, constant: 16).isActive = true
        courseDescriptionPlaceholder.leadingAnchor.constraint(equalTo: courseDescription.leadingAnchor, constant: 8).isActive = true
        courseDescriptionPlaceholder.trailingAnchor.constraint(equalTo: courseDescription.trailingAnchor, constant: -8).isActive = true
        
        courseDescriptionPlaceholder.isHidden = !courseDescription.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        courseDescriptionPlaceholder.isHidden = !textView.text.isEmpty
        courseDescriptionString = textView.text
        
        // 텍스트뷰 스크롤 없이 height 길어지게끔..
        let size = CGSize(width: scrollView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            
            if estimatedSize.height <= 180 {
                
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        courseTitle.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        courseTitle.layer.borderColor = UIColor.gray2.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        courseDescription.layer.borderColor = UIColor.black.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        courseDescription.layer.borderColor = UIColor.gray2.cgColor
    }
}
