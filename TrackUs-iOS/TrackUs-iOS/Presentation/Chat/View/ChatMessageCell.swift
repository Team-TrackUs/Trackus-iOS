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
    
    private lazy var leftSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rightSpacerView: UIView = {
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
        contentView.addSubview(messageBackgroundView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(leftSpacerView)
        contentView.addSubview(rightSpacerView)
        messageBackgroundView.addSubview(messageLabel)
        
        // 기본 공통 오토 레이아웃
        NSLayoutConstraint.activate([
            messageBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -8),
            messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -8),
            
            timeLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor),
            
            leftSpacerView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor),
            rightSpacerView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor)
        ])
    }
    
    // 날짜 출력
    func dateLabelSetup() {
        
    }
    
    @objc private func profileImageTap() {
        // 이미지 버튼 클릭
        print("이미지 클릭")
    }
    
    /// ui출력별 종류
    func configure(messageMap: MessageMap) {
        let isMyMessage = (messageMap.message.sendMember == User.currentUid)
        let message = messageMap.message
        
        var topAnchorPoint = contentView.topAnchor
        // 사용자 정보 가져오기
        guard let sendMember = ChatRoomManager.shared.userInfo[message.sendMember] else { return }
        
        messageLabel.text = message.text
        
        // 시간 출력 여부
        timeLabel.isHidden = messageMap.sameTime
        timeLabel.text = message.time
        
        
        // 날짜 출력 여부
        if !messageMap.sameDate {
            contentView.addSubview(dateLabel)
            NSLayoutConstraint.activate([
                dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ])
            dateLabel.text = message.date
            topAnchorPoint = dateLabel.bottomAnchor
        }
        
        profileImageView.topAnchor.constraint(equalTo: topAnchorPoint, constant: 8).isActive = true
        
        // 프로필 이미지파일 출력 여부
        if isMyMessage {
            profileImageView.isHidden = true
            NSLayoutConstraint.activate([
                messageBackgroundView.topAnchor.constraint(equalTo: topAnchorPoint, constant: 4),
                messageBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                timeLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: -8),
                timeLabel.leadingAnchor.constraint(equalTo: leftSpacerView.trailingAnchor, constant: 8),
                leftSpacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                //emptyView.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8)
            ])
            messageLabel.textColor = .white
            messageBackgroundView.backgroundColor = .mainBlue
        } else {
            
            rightSpacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
            // 프로필, 닉네임 출력 여부
            if !messageMap.sameUser || !messageMap.sameDate {
                profileImageView.isHidden = false
                if !contentView.subviews.contains(userNameLabel) {
                    contentView.addSubview(userNameLabel)
                }
                userNameLabel.text = sendMember.name.isEmpty ? "탈퇴 회원" : sendMember.name
                
                NSLayoutConstraint.activate([
                    profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    
                    userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4),
                    userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
                    
                    messageBackgroundView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
                    messageBackgroundView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant:8)
                ])
                if let url = ChatRoomManager.shared.userInfo[message.sendMember]?.profileImageUrl {
                    // Load image from URL (you may need an image loading library like SDWebImage)
                    ImageCacheManager.shared.loadImage(imageUrl: url, completionHandler: { image in
                        self.profileImageView.image = image
                    })
                }
                // 탭 제스처 추가
                //tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTap))
                //profileImageView.addGestureRecognizer(tapGestureRecognizer)
            } else {
                profileImageView.isHidden = true
                userNameLabel.isHidden = true
//                if contentView.subviews.contains(profileImageView) {
//                    profileImageView.removeFromSuperview()
//                }
//                if contentView.subviews.contains(userNameLabel) {
//                    userNameLabel.removeFromSuperview()
//                }
                NSLayoutConstraint.activate([
                    messageBackgroundView.topAnchor.constraint(equalTo: topAnchorPoint, constant: 4),
                    messageBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:64)
                ])
            }
            
            timeLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: 8).isActive = true
            timeLabel.trailingAnchor.constraint(equalTo: rightSpacerView.leadingAnchor, constant: -8).isActive = true
            messageLabel.textColor = .label
            messageBackgroundView.backgroundColor = .gray3
        }
        
        //contentView.layoutIfNeeded()
    }
}
