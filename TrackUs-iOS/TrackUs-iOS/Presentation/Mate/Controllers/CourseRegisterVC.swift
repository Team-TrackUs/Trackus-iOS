//
//  CourseRegisterVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/14/24.
//

import UIKit
import MapKit

class CourseRegisterVC: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - Properties
    
    lazy var testcoords: [CLLocationCoordinate2D] = [] // 좌표배열
    lazy var distance: CLLocationDistance = 0 // 거리
    var runningStyle: Int = 0 { // 러닝 스타일
        didSet {
            updateStyleButtonAppearance()
        }
    }
    var courseTitleString: String = "" // 코스 제목
    var courseDescriptionString: String = "" // 코스 소개글
    var personnel: Int = 1 // 인원수
    
    var isRegionSet = false // mapkit
    var locationManager = CLLocationManager() // mapkit
    var pinAnnotations: [MKPointAnnotation] = [] // mapkit
    
    let toolBarKeyboard: UIToolbar = {
        let toolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(btnDoneBarTapped))
        toolbar.sizeToFit()
        toolbar.items = [flexBarButton, doneButton]
        toolbar.tintColor = .blue
        return toolbar
    }()
    
    var drawMapView: MKMapView = {
        let mapview = MKMapView()
        return mapview
    }()
    
    private lazy var drawMapButton: UIButton = {
       let button = UIButton()
        
        button.setTitle("코스를 입력해주세요", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .blue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(drawMapButtonTapped), for: .touchUpInside)
        return button
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
    
    let contentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
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
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(walkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleFastWalkButton: UIButton = {
       let button = UIButton()
        button.setTitle("조깅", for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(FastwalkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleRuuningButton: UIButton = {
       let button = UIButton()
        button.setTitle("달리기", for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(RunningButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var styleSprintButton: UIButton = {
       let button = UIButton()
        button.setTitle("인터벌", for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(sprintButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var courseTitle: UITextField = {
        let title = UITextField()
        title.textColor = .black
        title.font = UIFont.systemFont(ofSize: 16)
        title.attributedPlaceholder = NSAttributedString(string: "저장할 러닝 이름을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        title.backgroundColor = .white
        title.frame = CGRect(x: 0, y: 0, width: 398, height: 48)
        title.layer.cornerRadius = 8
        title.layer.borderWidth = 1.0
        title.layer.borderColor = UIColor.gray.cgColor
        
        title.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        title.leftViewMode = .always
        
        title.inputAccessoryView = toolBarKeyboard
        
        return title
    }()
    
    private lazy var courseDescription: UITextView = {
        let description = UITextView()
        description.textColor = .black
        description.font = UIFont.systemFont(ofSize: 16)
        description.backgroundColor = .white
        description.layer.cornerRadius = 8
        description.layer.borderWidth = 1.0
        description.layer.borderColor = UIColor.gray.cgColor
        description.textContainerInset = UIEdgeInsets(top: 16, left: 4, bottom: 16, right: 4)
        description.inputAccessoryView = toolBarKeyboard
        
        return description
    }()
    
    private let courseDescriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "코스에 대한 자세한 설명을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private let datePicker: UIDatePicker = {
       let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko-KR")
        picker.backgroundColor = .white
        return picker
    }()
    
    private let timePicker: UIDatePicker = {
       let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko-KR")
        picker.backgroundColor = .white
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
    
    private let addCourseButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blue
        button.setTitle("코스 등록하기", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 56 / 2
        
        button.addTarget(self, action: #selector(addCourseButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let addCourseButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        label.text = "\(String(format: "%.2f", distance)) km"
        label.textColor = .white
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        label.layer.cornerRadius = 40 / 2
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        label.layer.shadowRadius = 6
        label.clipsToBounds = true
        
        return label
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        courseDescription.delegate = self
        setupPlaceholder()
        
        configureUI()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if testcoords.count != 0 {
            configureUI()
        }
    }
    
    // MARK: - Selectors
    
    @objc func walkButtonTapped() {
        runningStyle = 0
        print("runningStyle: \(runningStyle)")
    }
    
    @objc func FastwalkButtonTapped() {
        runningStyle = 1
        print("runningStyle: \(runningStyle)")
        print("DEBUG: CourseRegisterVC = \(testcoords.count)")
    }
    
    @objc func RunningButtonTapped() {
        runningStyle = 2
        print("runningStyle: \(runningStyle)")
    }
    
    @objc func sprintButtonTapped() {
        runningStyle = 3
        print("runningStyle: \(runningStyle)")
    }
    
    @objc func personUp() {
        if personnel < 10 {
            personnel += 1
            personnelLabel.text = String(personnel)
        }
    }
    
    @objc func personDown() {
        if personnel > 1 {
            personnel -= 1
            personnelLabel.text = String(personnel)
        }
    }
    
    @objc func addCourseButtonTapped() {
        print("DEBUG: Add course...")
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
    
    @objc func editMapButtonTapped() {
        self.testcoords.removeAll()
        print("DEBUG: \(testcoords.count)")
        
        for annotation in pinAnnotations {
            drawMapView.removeAnnotation(annotation)
        }
        pinAnnotations.removeAll()
        
        if let overlays = drawMapView.overlays as? [MKPolyline] {
            drawMapView.removeOverlays(overlays)
        }
        
        let courseDrawingMapVC = CourseDrawingMapVC()
        courseDrawingMapVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(courseDrawingMapVC, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.backgroundColor = .white
        scrollView.backgroundColor = .white
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) // 없애보기
        ])
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1100)
        ])
        
//        contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor).isActive = true
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        MapConfigureUI()
        
        if testcoords.count == 0 {
            contentView.addSubview(drawMapButton)
            drawMapButton.translatesAutoresizingMaskIntoConstraints = false
            drawMapButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
            drawMapButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            drawMapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            drawMapButton.widthAnchor.constraint(equalToConstant: 398).isActive = true
            drawMapButton.heightAnchor.constraint(equalToConstant: 310).isActive = true
            drawMapButton.layer.cornerRadius = 10
            
            contentView.addSubview(runningStyleLabel)
            runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
            runningStyleLabel.topAnchor.constraint(equalTo: drawMapButton.bottomAnchor, constant: 27).isActive = true
            runningStyleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        } else {
            contentView.addSubview(drawMapView)
            drawMapView.translatesAutoresizingMaskIntoConstraints = false
            drawMapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
            drawMapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            drawMapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            drawMapView.widthAnchor.constraint(equalToConstant: 398).isActive = true
            drawMapView.heightAnchor.constraint(equalToConstant: 310).isActive = true
            drawMapView.layer.cornerRadius = 10
            
            drawMapView.addSubview(editMapButton)
            editMapButton.translatesAutoresizingMaskIntoConstraints = false
            editMapButton.rightAnchor.constraint(equalTo: drawMapView.rightAnchor, constant: -8).isActive = true
            editMapButton.topAnchor.constraint(equalTo: drawMapView.topAnchor, constant: 8).isActive = true
            
            drawMapView.addSubview(distanceLabel)
            distanceLabel.translatesAutoresizingMaskIntoConstraints = false
            distanceLabel.leftAnchor.constraint(equalTo: drawMapView.leftAnchor, constant: 16).isActive = true
            distanceLabel.bottomAnchor.constraint(equalTo: drawMapView.bottomAnchor, constant: -30).isActive = true
            distanceLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
            distanceLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            contentView.addSubview(runningStyleLabel)
            runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
            runningStyleLabel.topAnchor.constraint(equalTo: drawMapView.bottomAnchor, constant: 27).isActive = true
            runningStyleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
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
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        stack.topAnchor.constraint(equalTo: runningStyleLabel.bottomAnchor, constant: 12).isActive = true
        
        contentView.addSubview(courseTitleLabel)
        courseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        courseTitleLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 27).isActive = true
        courseTitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        
        contentView.addSubview(courseTitle)
        courseTitle.translatesAutoresizingMaskIntoConstraints = false
        courseTitle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        courseTitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        courseTitle.topAnchor.constraint(equalTo: courseTitleLabel.bottomAnchor, constant: 12).isActive = true
        courseTitle.widthAnchor.constraint(equalToConstant: 398).isActive = true
        courseTitle.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        contentView.addSubview(courseDescriptionLabel)
        courseDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        courseDescriptionLabel.topAnchor.constraint(equalTo: courseTitle.bottomAnchor, constant: 27).isActive = true
        courseDescriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        
        contentView.addSubview(courseDescription)
        courseDescription.translatesAutoresizingMaskIntoConstraints = false
        courseDescription.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        courseDescription.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        courseDescription.topAnchor.constraint(equalTo: courseDescriptionLabel.bottomAnchor, constant: 12).isActive = true
        courseDescription.widthAnchor.constraint(equalToConstant: 398).isActive = true
        courseDescription.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
//        courseDescription.isScrollEnabled = false
        
        let datePickerStack = UIStackView(arrangedSubviews: [datePickerLabel, datePicker])
        datePickerStack.axis = .horizontal
        datePickerStack.spacing = 100
        
        contentView.addSubview(datePickerStack)
        datePickerStack.translatesAutoresizingMaskIntoConstraints = false
        datePickerStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        datePickerStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        datePickerStack.topAnchor.constraint(equalTo: courseDescription.bottomAnchor, constant: 27).isActive = true
        
        let timePickerStack = UIStackView(arrangedSubviews: [timePickerLabel, timePicker])
        timePickerStack.axis = .horizontal
        timePickerStack.spacing = 100
        
        contentView.addSubview(timePickerStack)
        timePickerStack.translatesAutoresizingMaskIntoConstraints = false
        timePickerStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        timePickerStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        timePickerStack.topAnchor.constraint(equalTo: datePickerStack.bottomAnchor, constant: 27).isActive = true
        
        let personnelButtonStack = UIStackView(arrangedSubviews: [personDownButton, personnelLabel, personUpButton])
        personnelButtonStack.axis = .horizontal
        personnelButtonStack.spacing = 8
//        personnelButtonStack.layer.cornerRadius = 8
//        personnelButtonStack.layer.borderColor = UIColor.gray.cgColor
//        personnelButtonStack.layer.borderWidth = 1.0
        
        let personnelStack = UIStackView(arrangedSubviews: [PeopleSettingsLabel, personnelButtonStack])
        personnelStack.axis = .horizontal
        personnelStack.spacing = 100
        
        contentView.addSubview(personnelStack)
        personnelStack.translatesAutoresizingMaskIntoConstraints = false
        personnelStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        personnelStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        personnelStack.topAnchor.constraint(equalTo: timePickerStack.bottomAnchor, constant: 27).isActive = true
        personnelStack.widthAnchor.constraint(equalToConstant: 116).isActive = true
        personnelStack.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        contentView.addSubview(addCourseButtonContainer)
        addCourseButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        addCourseButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        addCourseButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addCourseButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        addCourseButtonContainer.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        addCourseButtonContainer.addSubview(addCourseButton)
        addCourseButton.translatesAutoresizingMaskIntoConstraints = false
        addCourseButton.topAnchor.constraint(equalTo: addCourseButtonContainer.topAnchor, constant: 10).isActive = true
        addCourseButton.leftAnchor.constraint(equalTo: addCourseButtonContainer.leftAnchor).isActive = true
        addCourseButton.bottomAnchor.constraint(equalTo: addCourseButtonContainer.bottomAnchor).isActive = true
        addCourseButton.rightAnchor.constraint(equalTo: addCourseButtonContainer.rightAnchor).isActive = true
        
        updateStyleButtonAppearance()
        
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
        
//        // 텍스트뷰 스크롤 없이 height 길어지게끔..
//        let size = CGSize(width: contentView.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        
//        textView.constraints.forEach { (constraint) in
//            
//            if estimatedSize.height <= 180 {
//                
//            }
//            else {
//                if constraint.firstAttribute == .height {
//                    constraint.constant = estimatedSize.height
//                }
//            }
//        }
        
    }
    
    func updateStyleButtonAppearance() {
        styleWalkButton.setTitleColor(runningStyle == 0 ? .white : .gray, for: .normal)
        styleWalkButton.backgroundColor = runningStyle == 0 ? .blue : .white
        
        styleFastWalkButton.setTitleColor(runningStyle == 1 ? .white : .gray, for: .normal)
        styleFastWalkButton.backgroundColor = runningStyle == 1 ? .blue : .white
        
        styleRuuningButton.setTitleColor(runningStyle == 2 ? .white : .gray, for: .normal)
        styleRuuningButton.backgroundColor = runningStyle == 2 ? .blue : .white
        
        styleSprintButton.setTitleColor(runningStyle == 3 ? .white : .gray, for: .normal)
        styleSprintButton.backgroundColor = runningStyle == 3 ? .blue : .white
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
        drawMapView.center = view.center
        
        for (index, coord) in testcoords.enumerated() {
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            let pinTitle = "\(index + 1)" // 핀의 제목을 인덱스로 설정
            pin.title = pinTitle
            drawMapView.addAnnotation(pin)
            pinAnnotations.append(pin)
        }
        
        addPolylineToMap()
    }
    
}

extension CourseRegisterVC {
    
    // MARK: - MapKit
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // adding map region
        if testcoords.count > 0 {
            if !isRegionSet {
                
                let center = CLLocationCoordinate2D(latitude: testcoords[0].latitude, longitude: testcoords[0].longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                drawMapView.setRegion(region, animated: true) // 위치를 사용자의 위치로
                
                isRegionSet = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
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
//            label.text = pin.title ?? ""
            label.text = pin.title ?? "\(testcoords.count + 1)"
            label.textColor = .blue
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 12)
            
            label.backgroundColor = .white
            label.layer.borderColor = UIColor.blue.cgColor
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
}
