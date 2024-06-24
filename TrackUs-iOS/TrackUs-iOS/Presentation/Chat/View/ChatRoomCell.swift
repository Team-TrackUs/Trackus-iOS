//
//  ChatListCell.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/29/24.
//

import UIKit

class ChatRoomCell: UITableViewCell {
    //     채팅방 제목
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // 최근 메세지
    private lazy var latestMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray2
        return label
    }()
    
    // 최근 메세지 갯수
    private lazy var unreadCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.red.cgColor
        label.backgroundColor = .red
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    // 최근 메세지 배경
    private lazy var countBackgroundView: UIView = {
        let countBackgroundView = UIView()
        countBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        countBackgroundView.layer.cornerRadius = 10
        countBackgroundView.backgroundColor = .red
        return countBackgroundView
    }()
    
    // 최근 메세지 날짜
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray1
        return label
    }()
    
    // 멤버 수
    private lazy var membersCountlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray1
        return label
    }()
    private lazy var chatProfileImageView: ChatProfileImageView = {
        let view = ChatProfileImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(chatProfileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(membersCountlabel)
        contentView.addSubview(latestMessageLabel)
        contentView.addSubview(timestampLabel)
        //contentView.addSubview(unreadCountLabel)
        contentView.addSubview(countBackgroundView)
        countBackgroundView.addSubview(unreadCountLabel)
        
        NSLayoutConstraint.activate([
            chatProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chatProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chatProfileImageView.widthAnchor.constraint(equalToConstant: 50),
            chatProfileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: chatProfileImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: chatProfileImageView.topAnchor),
            
            membersCountlabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            membersCountlabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            latestMessageLabel.leadingAnchor.constraint(equalTo: chatProfileImageView.trailingAnchor, constant: 12),
            latestMessageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            latestMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
            
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timestampLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            
            unreadCountLabel.topAnchor.constraint(equalTo: countBackgroundView.topAnchor, constant: 2),
            unreadCountLabel.bottomAnchor.constraint(equalTo: countBackgroundView.bottomAnchor, constant: -2),
            unreadCountLabel.leadingAnchor.constraint(equalTo: countBackgroundView.leadingAnchor, constant: 6),
            unreadCountLabel.trailingAnchor.constraint(equalTo: countBackgroundView.trailingAnchor, constant: -6),
            
            countBackgroundView.trailingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            countBackgroundView.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with chat: Chat, users: [String: User]) {
        chatProfileImageView.configure(with: chat.nonSelfMembers)
        
        if chat.group {
            titleLabel.text = chat.title
            membersCountlabel.text = String(chat.members.values.filter{ $0 == true }.count)
            membersCountlabel.isHidden = false
        } else {
            titleLabel.text = users[chat.nonSelfMembers.first ?? ""]?.name ?? "TrackUs"
            membersCountlabel.text = ""
            membersCountlabel.isHidden = true
        }
        
        if chat.group {
            //            let membersCount = chat.members.count
            //            titleLabel.text = "\(titleLabel.text ?? "") (\(membersCount))"
        }
        
        latestMessageLabel.text = chat.latestMessage?.text ?? "작성된 메세지가 없습니다."
        timestampLabel.text = chat.latestMessage?.timestamp?.timeAgoFormat() ?? ""
        
        if let unreadCount = chat.usersUnreadCountInfo[User.currentUid], unreadCount > 0 {
            unreadCountLabel.text = unreadCount <= 300 ? "\(unreadCount)" : "300+"
            countBackgroundView.isHidden = false
        } else {
            countBackgroundView.isHidden = true
        }
    }
}
