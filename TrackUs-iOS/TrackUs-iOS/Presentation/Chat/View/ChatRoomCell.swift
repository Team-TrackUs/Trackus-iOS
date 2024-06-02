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
            label.textColor = .gray1
            return label
        }()
        
        // 최근 메세지 갯수
        private lazy var unreadCountLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 6
            label.backgroundColor = .red
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .white
            return label
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
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .gray1
            return label
        }()
    private let chatProfileImageView = ChatProfileImageView()
    
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
        contentView.addSubview(unreadCountLabel)
        
        chatProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        latestMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        unreadCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chatProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            chatProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chatProfileImageView.widthAnchor.constraint(equalToConstant: 52),
            chatProfileImageView.heightAnchor.constraint(equalToConstant: 52),
            
            titleLabel.leadingAnchor.constraint(equalTo: chatProfileImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            membersCountlabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            membersCountlabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            latestMessageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            latestMessageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            timestampLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            
            unreadCountLabel.trailingAnchor.constraint(equalTo: timestampLabel.trailingAnchor),
            unreadCountLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with chat: Chat, users: [String: User]) {
        chatProfileImageView.configure(with: chat.nonSelfMembers, users: users)
        
        if chat.group {
            titleLabel.text = chat.title
            membersCountlabel.text = String(chat.members.values.filter{ $0 == true }.count)
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
            unreadCountLabel.text = "\(unreadCount)"
        } else {
            unreadCountLabel.text = ""
        }
    }
}
