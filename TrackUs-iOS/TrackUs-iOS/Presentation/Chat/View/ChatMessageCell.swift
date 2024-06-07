//
//  ChatMessageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/3/24.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    
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
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        messageBackgroundView.addSubview(messageLabel)
        
        // 레이블의 content hugging priority를 설정
        messageBackgroundView.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        spacerView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
    }
    
    @objc private func profileImageTap() {
        // 이미지 버튼 클릭
        print("이미지 클릭")
    }
    
    /// ui출력별 종류
    func configure(messageMap: MessageMap) {
        let isMyMessage = (messageMap.message.sendMember == User.currentUid)
        let message = messageMap.message
        
        // 제약조건 리스트
        NSLayoutConstraint.deactivate(contentView.constraints)
        var constraints = [NSLayoutConstraint]()
        // 사용자 정보 가져오기
        guard let sendMember = ChatRoomManager.shared.userInfo[message.sendMember] else { return }
        
        messageLabel.text = message.text
        
        // 공통 제약조건
        constraints.append(messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 8))
        constraints.append(messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -8))
        constraints.append(messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 8))
        constraints.append(messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -8))
        
        constraints.append(messageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-4))
        constraints.append(messageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64))
        
        constraints.append(timeLabel.bottomAnchor.constraint(equalTo: messageStackView.bottomAnchor))
        
        // 날짜 출력 여부
        if messageMap.sameDate {
            dateLabel.isHidden = true
            //topAnchorPoint = dateLabel.bottomAnchor
        } else {
            dateLabel.isHidden = false
            constraints.append(dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8))
            constraints.append(dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
            constraints.append(dateLabel.heightAnchor.constraint(equalToConstant: 16))
            dateLabel.text = message.date
        }
        
        // 프로필 이미지파일 출력 여부
        if isMyMessage {
            constraints.append(messageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-16))
            constraints.append(timeLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: -4))
            messageStackView.addArrangedSubview(spacerView)
            messageStackView.addArrangedSubview(messageBackgroundView)
            
            
            profileImageView.isHidden = true
            userNameLabel.isHidden = true
            timeLabel.textAlignment = .right
            constraints.append(messageStackView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 4))
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
                constraints.append(profileImageView.topAnchor.constraint(equalTo: dateLabel.isHidden ? contentView.topAnchor : dateLabel.bottomAnchor, constant: 4))
                constraints.append(profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
                constraints.append(profileImageView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56))
                constraints.append(profileImageView.widthAnchor.constraint(equalToConstant: 40))
                constraints.append(profileImageView.heightAnchor.constraint(equalToConstant: 40))
                
                constraints.append(userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor))
                constraints.append(userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8))
                constraints.append(userNameLabel.heightAnchor.constraint(equalToConstant: 12))
                constraints.append(messageStackView.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 16))
                //constraints.append(messageBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8))
                
                // 사용자 이미지 있을 경우 이미지 표시 - 없을경우 기본
                if let url = sendMember.profileImageUrl {
                    profileImageView.loadImage(url: url)
                }
                userNameLabel.text = sendMember.name.isEmpty ? "탈퇴 회원" : sendMember.name
                
                // 탭 제스처 추가
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTap))
                profileImageView.addGestureRecognizer(tapGestureRecognizer)
                
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
        //contentView.layoutIfNeeded()
    }
}
