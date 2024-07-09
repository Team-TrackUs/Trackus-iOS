//
//  ChatMessageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/3/24.
//

import UIKit

protocol UserCellDelegate: AnyObject {
    func didTapProfileImage(for uid: String)
}


class ChatMessageCell: UITableViewCell {
    
    weak var delegate: UserCellDelegate?
    private var uid: String = ""
    
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
        messageBackgroundView.addSubview(messageLabel)
        profileImageView.addSubview(overlayerView)
        overlayerView.addSubview(iconView)
        
        // 레이블의 content hugging priority를 설정
        messageBackgroundView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        spacerView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
    }
    
    @objc private func didTapProfileImage() {
        delegate?.didTapProfileImage(for: uid)
    }
    
    /// ui출력별 종류
    func configure(messageMap: MessageMap) {
        self.uid = messageMap.message.sendMember
        let message = messageMap.message
        var sendMember: User
        
        // 제약조건 초기화
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        var constraints = [NSLayoutConstraint]()
        // 사용자 정보 가져오기
        if let member = ChatManager.shared.userInfo[message.sendMember] {
            sendMember = member
        } else {
            // 탈퇴 회원
            sendMember = User()
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
                return
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
        
        constraints.append(messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-4))
        constraints.append(messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
        
        constraints.append(timeLabel.bottomAnchor.constraint(equalTo: messageStackView.bottomAnchor))
        
        // 프로필 이미지파일 출력 여부
        if isMyMessage {
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-16))
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: -4))
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(messageBackgroundView)
            
            
            profileImageView.isHidden = true
            userNameLabel.isHidden = true
            timeLabel.textAlignment = .right
            constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 2))
            messageLabel.textColor = .white
            messageBackgroundView.backgroundColor = .mainBlue
        } else {
            
            messageStackView.addArrangedSubview(messageBackgroundView)
            messageStackView.addArrangedSubview(spacerView)
            timeLabel.textAlignment = .left
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-64))
            constraints.append(timeLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: 4))
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
                
                //UIImage(systemName: "exclamationmark.circle")
                //UIImage(systemName: "nosign")

            } else {
                profileImageView.isHidden = true
                userNameLabel.isHidden = true
                
                constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 4))
                constraints.append(messageBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
                
            }
            messageLabel.textColor = .label
            messageBackgroundView.backgroundColor = .gray3
        }
        
        // 시간 출력 여부
        if messageMap.sameTime {
            timeLabel.isHidden = true
        }else {
            timeLabel.isHidden = false
            timeLabel.text = message.time
        }
        
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
        
        // 공통 view
        messageStackView.isHidden = false
        imageMessageView.isHidden = false
        
        constraints.append(imageMessageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant:-128))
        // 이미지 캐싱
        imageMessageView.loadImage(url: imageUrl) {}
        // 공통 제약조건
        constraints.append(messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-4))
        constraints.append(messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
        
        constraints.append(timeLabel.bottomAnchor.constraint(equalTo: messageStackView.bottomAnchor))
        
        // 프로필 이미지파일 출력 여부
        if isMyMessage {
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-16))
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: imageMessageView.leadingAnchor, constant: -4))
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(imageMessageView)
            
            
            profileImageView.isHidden = true
            userNameLabel.isHidden = true
            timeLabel.textAlignment = .right
            constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 2))
        } else {
            
            messageStackView.addArrangedSubview(imageMessageView)
            messageStackView.addArrangedSubview(spacerView)
            timeLabel.textAlignment = .left
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-64))
            constraints.append(timeLabel.leadingAnchor.constraint(equalTo: imageMessageView.trailingAnchor, constant: 4))
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
                constraints.append(imageMessageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
                
            }
        }
        
        // 시간 출력 여부
        if messageMap.sameTime {
            timeLabel.isHidden = true
        }else {
            timeLabel.isHidden = false
            timeLabel.text = message.time
        }
        
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
}
