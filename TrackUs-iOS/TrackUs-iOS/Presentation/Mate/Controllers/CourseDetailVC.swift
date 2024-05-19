//
//  CourseDetailVC.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/17/24.
//

import UIKit

class CourseDetailVC: UIViewController {
    
    // MARK: - Properties
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let mapImageButton: UIButton = { // 코스 지도 이미지
        let button = UIButton()
        button.setImage(UIImage(named: ""), for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .mainBlue
        button.addTarget(self, action: #selector(goCourseDetail), for: .touchUpInside)
        return button
    }()
    
    private let distanceLabel: UILabel = { // 코스 거리
        let label = UILabel()
        label.text = "1.3 km"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = .mainBlue
        label.layer.cornerRadius = 30
        return label
    }()
    
    private let dateLabel: UILabel = { // 코스 날짜
        let label = UILabel()
        label.text = "2024.01.12"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private let runningStyleLabel: UILabel = { // 러닝스타일
        let label = UILabel()
        label.text = "인터벌"
        label.font = .boldSystemFont(ofSize: 12)
        label.backgroundColor = .mainBlue
        label.textColor = .white
        label.textAlignment = .center
        label.layer.frame = CGRect(x: 0, y: 0, width: 63, height: 20)
        label.layer.cornerRadius = 20 / 2
        label.layer.masksToBounds = true
        return label
    }()
    
    private let courseTitleLabel: UILabel = { // 코스 제목
        let label = UILabel()
        label.text = "30분 가볍게 러닝해요!"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let courseLocationLabel: UILabel = { // 코스 장소
        let label = UILabel()
        label.text = "서울숲 카페 거리"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let locationIcon = UIImageView(image: UIImage(named: "pin_icon"))
    
    private let courseTimeLabel: UILabel = { // 코스 시간
        let label = UILabel()
        label.text = "10:02 AM"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let timeIcon = UIImageView(image: UIImage(named: "time_icon"))
    
    private let courseDestriptionLabel: UILabel = { // 코스 소개글
        let label = UILabel()
        label.text = "여름이 끝나갈 무렵, 늦은 오후의 따스한 햇살이 나뭇잎 사이로 부서지며 공원을 산책하는 사람들의 얼굴에 은은하게 내려앉고, 바람은 살짝 선선해져서 긴 팔 옷을 입어야 할지 고민하게 만들었으며, 아이들은 여전히 놀이터에서 뛰어다니며 즐거운 웃음소리를 내고, 벤치에 앉은 연인들은 서로의 손을 꼭 잡고 낮은 목소리로 이야기를 나누고 있었고, 강아지를 산책시키는 사람들은 가끔 강아지가 지나가는 다람쥐를 쫓아가려는 것을 막느라 애쓰며, 공원 한쪽에서는 아마추어 음악가들이 모여 기타를 치고 노래를 부르며 즉흥적인 공연을 펼치고 있었고, 그 옆에서는 몇몇 사람들이 자전거를 타고 천천히 공원을 도는 여유를 즐기고 있었으며, 공원의 작은 연못에는 오리가 유유히 떠다니며 물속을 헤엄치고 있었고, 해가 서서히 지면서 하늘은 분홍빛과 주황빛으로 물들기 시작하며, 이 모든 장면들이 한데 어우러져 평화롭고 아름다운 일요일 오후의 한 순간을 만들어내고 있었다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let courseEnterButton: UIButton = { // 트랙 참여 버튼
        let button = UIButton(type: .system)
        button.backgroundColor = .mainBlue
        button.setTitle("트랙 참가하기", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 56 / 2
        
        button.addTarget(self, action: #selector(courseEnterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private let goChatRoomButton: UIButton = { // 채팅방 이동 버튼
        let button = UIButton(type: .system)
//        button.backgroundColor = .blue
        button.setImage(UIImage(named: "chatBubble_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        button.imageView?.layer.transform = CATransform3DMakeScale(1.1, 1.3, 1.3)
//        button.imageView?.layer.transform = CATransform3DMakeScale(1.0, 1.3, 1.3)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        button.addTarget(self, action: #selector(goChatRoomButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func goCourseDetail() {
        print("DEBUG: 지도클릭")
        let courseMapVC = CourseMapVC()
        self.navigationController?.pushViewController(courseMapVC, animated: true)
    }
    
    @objc func courseEnterButtonTapped() {
        print("DEBUG: 참가하기 클릭")
    }
    
    @objc func goChatRoomButtonTapped() {
        print("DEBUG: 채팅 버튼 클릭")
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
        
        scrollView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: mapImageButton.bottomAnchor, constant: 16).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16).isActive = true
        
        scrollView.addSubview(runningStyleLabel)
        runningStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        runningStyleLabel.topAnchor.constraint(equalTo: mapImageButton.bottomAnchor, constant: 16).isActive = true
        runningStyleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -16).isActive = true
        runningStyleLabel.widthAnchor.constraint(equalToConstant: 63).isActive = true
        runningStyleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
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
        
        let locationTimeStack = UIStackView()
        locationTimeStack.axis = .horizontal
        locationTimeStack.spacing = 5
        
        stackView.addArrangedSubview(locationTimeStack)
        locationTimeStack.translatesAutoresizingMaskIntoConstraints = false
        locationTimeStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
    
        locationTimeStack.addArrangedSubview(locationIcon)
        locationIcon.contentMode = .scaleAspectFit
        locationIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        locationIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true

        locationTimeStack.addArrangedSubview(courseLocationLabel)

        locationTimeStack.addArrangedSubview(timeIcon)
        timeIcon.contentMode = .scaleAspectFit
        timeIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        timeIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true

        locationTimeStack.addArrangedSubview(courseTimeLabel)
        
        let spacer = UIView()
        locationTimeStack.addArrangedSubview(spacer)
        
        stackView.addArrangedSubview(courseDestriptionLabel)
        courseDestriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        courseDestriptionLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 16).isActive = true
        courseDestriptionLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -16).isActive = true
        
//        let buttonStack = UIStackView(arrangedSubviews: [courseEnterButton, goChatRoomButton])
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fill // dldl
        
        buttonStack.addArrangedSubview(courseEnterButton)
        buttonStack.widthAnchor.constraint(equalToConstant: 335).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        buttonStack.addArrangedSubview(goChatRoomButton)
        goChatRoomButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        goChatRoomButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        buttonContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 10).isActive = true
        buttonStack.leftAnchor.constraint(equalTo: buttonContainer.leftAnchor).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor).isActive = true
        buttonStack.rightAnchor.constraint(equalTo: buttonContainer.rightAnchor).isActive = true
    }
}


/*
 
 "4명의 TrackUs 회원이 이 러닝 모임에 참여중입니다!"
 참여한 사람의 이미지와 이름 Cell을 만들기
 
 */
