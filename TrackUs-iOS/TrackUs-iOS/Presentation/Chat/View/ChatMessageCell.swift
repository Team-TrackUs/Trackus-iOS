//
//  ChatMessageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/3/24.
//

import UIKit
import MapKit

protocol ChatMessageCellDelegate: AnyObject {
    func didTapProfileImage(for uid: String)
    func didTapImageMessage(for userName: String, dateString: String, image: UIImage?)
    func didTapMapMessage(for coordinate: CLLocationCoordinate2D)
}


class ChatMessageCell: UITableViewCell, MKMapViewDelegate {
    
    weak var delegate: ChatMessageCellDelegate?
    private var uid: String = ""
    private var sendMember: User = User()
    private var sendDate: String = ""
    private var coordinate: CLLocationCoordinate2D?
    
    private lazy var dateLabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray2
        return dateLabel
    }()
    
    private lazy var profileImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지로 설정
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .gray3
        profileImageView.isUserInteractionEnabled = true
        return profileImageView
    }()
    private lazy var userNameLabel = {
        let userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = UIFont.systemFont(ofSize: 12)
        userNameLabel.textColor = .gray1
        return userNameLabel
    }()
    // MARK: - 사용자 InOut
    private lazy var inoutLabel = {
        let inoutLabel = UILabel()
        inoutLabel.translatesAutoresizingMaskIntoConstraints = false
        inoutLabel.font = UIFont.systemFont(ofSize: 12)
        inoutLabel.textColor = .gray1
        return inoutLabel
    }()
    
    // 이미지 메세지 관련
    private lazy var imageMessageView: UIImageView = {
        let imageView = AspectFitImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .gray3
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // MARK: - 메세지 관련
    private lazy var messageLabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    private lazy var timeLabel = {
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray2
        return timeLabel
    }()
    private lazy var messageBackgroundView = {
        let messageBackgroundView = UIView()
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        messageBackgroundView.layer.cornerRadius = 10
        return messageBackgroundView
    }()
    
    private lazy var messageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.sizeToFit()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    private lazy var mapMessageView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .gray3
        return view
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray3
        return imageView
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 기본 제약 조건
    private func setupViews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageStackView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(inoutLabel)
        contentView.addSubview(mapMessageView)
        messageBackgroundView.addSubview(messageLabel)
        profileImageView.addSubview(overlayerView)
        overlayerView.addSubview(iconView)
        
        // 레이블의 content hugging priority를 설정
        messageBackgroundView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        spacerView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
    }
    
    // 프로필 이미지 탭 이벤트
    @objc private func didTapProfileImage() {
        delegate?.didTapProfileImage(for: uid)
    }
    
    // 이미지 메세지 탭 이벤트
    @objc private func didTapImageMessage() {
        if let delegate = delegate {
            delegate.didTapImageMessage(for: sendMember.name, dateString: sendDate, image: imageMessageView.image)
        }
    }
    
    // Map 상세보기 탭 이벤트
    @objc private func didTapMapMessage() {
        if let delegate = delegate, let coordinate = coordinate {
            delegate.didTapMapMessage(for: coordinate)
        }
    }
    
    /// ui출력별 종류
    func configure(messageMap: MessageMap) {
        self.uid = messageMap.message.sendMember
        let message = messageMap.message
        
        // 제약조건 초기화
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        var constraints = [NSLayoutConstraint]()
        // 사용자 정보 가져오기
        if let member = ChatManager.shared.userInfo[message.sendMember] {
            self.sendMember = member
        } else {
            // 탈퇴 회원
            self.sendMember = User()
        }
        
        // 날짜 출력 여부 (공통)
        if messageMap.sameDate {
            dateLabel.isHidden = true
            //topAnchorPoint = dateLabel.bottomAnchor
        } else {
            dateLabel.isHidden = false
            constraints.append(dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4))
            constraints.append(dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
            constraints.append(dateLabel.heightAnchor.constraint(equalToConstant: 28))
            dateLabel.text = message.date
        }
        
        
        switch message.messageType {
            case .text:
                textMessgeSetup(messageMap: messageMap, sendMember: sendMember)
            case .image:
                imageSetUp(messageMap: messageMap, sendMember: sendMember)
            case .location:
                locationSetUp(messageMap: messageMap, sendMember: sendMember)
            case .userInout:
                InOutSetup(messageMap: messageMap, sendMember: sendMember)
        }
        
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 사용자 메세지 view 세팅
    func textMessgeSetup(messageMap: MessageMap, sendMember: User) {
        let isMyMessage = (messageMap.message.sendMember == User.currentUid)
        let message = messageMap.message
        
        var constraints = [NSLayoutConstraint]()
        
        // 관련없는 view 숨기기
        inoutLabel.isHidden = true
        imageMessageView.isHidden = true
        mapMessageView.isHidden = true
        
        // 공통 view
        messageLabel.isHidden = false
        messageStackView.isHidden = false
        messageBackgroundView.isHidden = false
        
        messageLabel.text = message.text
        
        // 공통 제약조건
        constraints.append(messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 8))
        constraints.append(messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -8))
        constraints.append(messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 8))
        constraints.append(messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -8))
        
        //constraints.append(messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-4))
        //constraints.append(messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
        
        //constraints.append(timeLabel.bottomAnchor.constraint(equalTo: messageStackView.bottomAnchor))
        
        if uid == User.currentUid {
            messageLabel.textColor = .white
            messageBackgroundView.backgroundColor = .mainBlue
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(messageBackgroundView)
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: -4))
        }else {
            messageLabel.textColor = .label
            messageBackgroundView.backgroundColor = .gray3
            messageStackView.addArrangedSubview(messageBackgroundView)
            messageStackView.addArrangedSubview(spacerView)
            constraints.append(timeLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: 4))
        }
        // 프로필 사진 출력 여부 세팅
        profileImageSetUp(messageMap: messageMap)
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }
    
    
    /// 이미지 메세지 셋업
    func imageSetUp(messageMap: MessageMap, sendMember: User) {
        let isMyMessage = (messageMap.message.sendMember == User.currentUid)
        let message = messageMap.message
        guard let imageUrl = message.imageUrl else { return }
        var constraints = [NSLayoutConstraint]()
        
        // 관련없는 view 숨기기
        inoutLabel.isHidden = true
        messageBackgroundView.isHidden = true
        mapMessageView.isHidden = true
        
        // 공통 view
        messageStackView.isHidden = false
        imageMessageView.isHidden = false
        
        constraints.append(imageMessageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant:-128))
        // 이미지 캐싱
        imageMessageView.loadImage(url: imageUrl) {}
        
        // 탭 이벤트 추가
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageMessage))
        imageMessageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.sendDate = message.date + " " + message.time
        
        if uid == User.currentUid {
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(imageMessageView)
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: imageMessageView.leadingAnchor, constant: -4))
        }else {
            messageStackView.addArrangedSubview(imageMessageView)
            messageStackView.addArrangedSubview(spacerView)
            constraints.append(timeLabel.leadingAnchor.constraint(equalTo: imageMessageView.trailingAnchor, constant: 4))
        }
        profileImageSetUp(messageMap: messageMap)
        
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 위치정보 셋업
    func locationSetUp(messageMap: MessageMap, sendMember: User) {
        let isMyMessage = (messageMap.message.sendMember == User.currentUid)
        let message = messageMap.message
        guard let location = message.location else { return }
        var constraints = [NSLayoutConstraint]()
        
        // 관련없는 view 숨기기
        inoutLabel.isHidden = true
        messageBackgroundView.isHidden = true
        imageMessageView.isHidden = true
        
        // 공통 view
        messageStackView.isHidden = false
        mapMessageView.isHidden = false
        
        
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isUserInteractionEnabled = false // 썸네일로만 사용하기 위해 상호작용 비활성화
        mapView.delegate = self
        
        let detailButton = UIButton()
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.setTitle("상세보기", for: .normal)
        detailButton.setTitleColor(.label, for: .normal)
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailButton.layer.cornerRadius = 10
        detailButton.layer.masksToBounds = true
        detailButton.backgroundColor = .gray3
        detailButton.addTarget(self, action: #selector(didTapMapMessage), for: .touchUpInside)
        
        let locationMarker = UIImageView(image: UIImage(named: "MarkerPin"))
        locationMarker.translatesAutoresizingMaskIntoConstraints = false
        
        let mapImageView = UIImageView()
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.image = nil
        
        // 좌표 이동
        self.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        guard let coordinate = coordinate else { return }
        
        mapImageView.addSubview(locationMarker)
        // 맵 미리보기 이미지 처리
        generateMapThumbnail(center: coordinate) { image in
            mapImageView.image = image
        }
        
        // 기존 남아있는 뷰 제거
        for subview in mapMessageView.subviews {
            if subview is UIImageView || subview is MKMapView {
                subview.removeFromSuperview()
            }
        }
        
        //mapMessageView.addSubview(mapView)
        mapMessageView.addSubview(mapImageView)
        mapMessageView.addSubview(detailButton)
        //constraints.append(mapMessageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -128))
        constraints.append(mapMessageView.widthAnchor.constraint(equalToConstant: 200))
        constraints.append(mapMessageView.heightAnchor.constraint(equalToConstant: 200))
        
        constraints.append(mapImageView.topAnchor.constraint(equalTo: mapMessageView.topAnchor))
        constraints.append(mapImageView.leadingAnchor.constraint(equalTo: mapMessageView.leadingAnchor))
        constraints.append(mapImageView.trailingAnchor.constraint(equalTo: mapMessageView.trailingAnchor))
        constraints.append(mapImageView.bottomAnchor.constraint(equalTo: mapMessageView.bottomAnchor))
        
        constraints.append(detailButton.leadingAnchor.constraint(equalTo: mapMessageView.leadingAnchor, constant: 4))
        constraints.append(detailButton.trailingAnchor.constraint(equalTo: mapMessageView.trailingAnchor, constant: -4))
        constraints.append(detailButton.bottomAnchor.constraint(equalTo: mapMessageView.bottomAnchor, constant: -4))
        constraints.append(detailButton.heightAnchor.constraint(equalToConstant: 40))
        
        constraints.append(locationMarker.centerXAnchor.constraint(equalTo: mapImageView.centerXAnchor))
        constraints.append(locationMarker.bottomAnchor.constraint(equalTo: mapImageView.centerYAnchor))
        constraints.append(locationMarker.widthAnchor.constraint(equalToConstant: 27))
        constraints.append(locationMarker.heightAnchor.constraint(equalToConstant: 39))
        
        self.sendDate = message.date + " " + message.time
        if uid == User.currentUid {
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(mapMessageView)
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: mapMessageView.leadingAnchor, constant: -4))
        }else {
            messageStackView.addArrangedSubview(mapMessageView)
            messageStackView.addArrangedSubview(spacerView)
            constraints.append(timeLabel.leadingAnchor.constraint(equalTo: mapMessageView.trailingAnchor, constant: 4))
        }
        profileImageSetUp(messageMap: messageMap)
        
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }

    
    /// 사용자 출입 정보 view 셋업
    func InOutSetup(messageMap: MessageMap, sendMember: User) {
        let message = messageMap.message
        
        // 연관 없는 뷰 숨기기
        profileImageView.isHidden = true
        userNameLabel.isHidden = true
        messageStackView.isHidden = true
        timeLabel.isHidden = true
        
        inoutLabel.isHidden = false
        
        guard let userInOut = message.userInOut else { return }
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(inoutLabel.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: dateLabel.isHidden ? 8 : 2))
        constraints.append(inoutLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        constraints.append(inoutLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8))
        
        // 사용자 나가기, 들어오기 여부 확인, true: 들어오기, false: 나가기
        inoutLabel.text = userInOut ? sendMember.name + "님이 들어왔습니다." : sendMember.name + "님이 나갔습니다."
        
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 프로필 사진 출력 여부 세팅
    func profileImageSetUp(messageMap: MessageMap) {
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-4))
        constraints.append(messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
        
        constraints.append(timeLabel.bottomAnchor.constraint(equalTo: messageStackView.bottomAnchor))
        
        // 프로필 이미지파일 출력 여부
        if uid == User.currentUid {
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-16))
            
            profileImageView.isHidden = true
            userNameLabel.isHidden = true
            timeLabel.textAlignment = .right
            constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 2))
        } else {
            timeLabel.textAlignment = .left
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-64))
            
            // 프로필, 닉네임 출력 여부
            if !messageMap.sameUser || !messageMap.sameDate {
                profileImageView.isHidden = false
                userNameLabel.isHidden = false
                constraints.append(profileImageView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 2))
                constraints.append(profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
                constraints.append(profileImageView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56))
                constraints.append(profileImageView.widthAnchor.constraint(equalToConstant: 40))
                constraints.append(profileImageView.heightAnchor.constraint(equalToConstant: 40))
                
                constraints.append(userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor))
                constraints.append(userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8))
                constraints.append(userNameLabel.heightAnchor.constraint(equalToConstant: 12))
                constraints.append(messageStackView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 16))
                
                // 사용자 이미지 있을 경우 이미지 표시 - 없을경우 기본
                profileImageView.loadProfileImage(url: sendMember.profileImageUrl) {}
                    
                userNameLabel.text = sendMember.name.isEmpty ? "(탈퇴 회원)" : sendMember.name
                
                if sendMember.isBlock {
                    // 정지 사용자
                    iconView.image = UIImage(systemName: "exclamationmark.circle")
                    overlayerView.isHidden = false
                    constraints.append(overlayerView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor))
                    constraints.append(overlayerView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor))
                    constraints.append(overlayerView.widthAnchor.constraint(equalToConstant: 40))
                    constraints.append(overlayerView.heightAnchor.constraint(equalToConstant: 40))
                    constraints.append(iconView.widthAnchor.constraint(equalToConstant: 20))
                    constraints.append(iconView.heightAnchor.constraint(equalToConstant: 20))
                    constraints.append(iconView.centerXAnchor.constraint(equalTo: overlayerView.centerXAnchor))
                    constraints.append(iconView.centerYAnchor.constraint(equalTo: overlayerView.centerYAnchor))
                } else if let blockedUserList = UserManager.shared.user.blockedUserList, blockedUserList.contains(sendMember.uid) {
                    // 차단 사용자
                    iconView.image = UIImage(systemName: "nosign")
                    overlayerView.isHidden = false
                    constraints.append(overlayerView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor))
                    constraints.append(overlayerView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor))
                    constraints.append(overlayerView.widthAnchor.constraint(equalToConstant: 40))
                    constraints.append(overlayerView.heightAnchor.constraint(equalToConstant: 40))
                    constraints.append(iconView.widthAnchor.constraint(equalToConstant: 20))
                    constraints.append(iconView.heightAnchor.constraint(equalToConstant: 20))
                    constraints.append(iconView.centerXAnchor.constraint(equalTo: overlayerView.centerXAnchor))
                    constraints.append(iconView.centerYAnchor.constraint(equalTo: overlayerView.centerYAnchor))
                } else {
                    overlayerView.isHidden = true
                }
                
                // 탭 제스처 추가
                if !sendMember.name.isEmpty {
                    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
                    profileImageView.addGestureRecognizer(tapGestureRecognizer)
                }

            } else {
                profileImageView.isHidden = true
                userNameLabel.isHidden = true
                constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 4))
            }
        }
        
        // 시간 출력 여부
        if messageMap.sameTime {
            timeLabel.isHidden = true
        }else {
            timeLabel.isHidden = false
            timeLabel.text = messageMap.message.time
        }
        
        // 제약조건 추가
        NSLayoutConstraint.activate(constraints)
    }
    
    func generateMapThumbnail(center: CLLocationCoordinate2D, completion: @escaping (UIImage) -> Void) {
        let location = String(center.latitude)+String(center.longitude)
        ImageCacheManager.shared.loadImage(location: location) { image in
            if let image = image {
                // 캐싱 되어있는 경우
                completion(image)
            } else {
                // 캐싱 안된 경우
                let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
                    mapView.setRegion(region, animated: false)
                    
                let options = MKMapSnapshotter.Options()
                options.mapType = mapView.mapType
                options.region = mapView.region
                options.showsPointsOfInterest = false
                options.showsBuildings = false
                options.size = CGSize(width: 200, height: 200) // 원하는 이미지 크기 설정

                let snapshotter = MKMapSnapshotter(options: options)
                snapshotter.start { snapshot, error in
                    guard let snapshot = snapshot else {
                        return
                    }

                    let image = snapshot.image
                    // 이미지 캐시 등록
                    ImageCacheManager.shared.setImage(image: image, url: String(center.latitude)+String(center.longitude))
                    completion(image)
                }
            }
        }
    }
}
