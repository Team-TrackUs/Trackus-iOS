//
//  MemberCellTableViewCell.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/20/24.
//

import UIKit

class MemberCell: UITableViewCell {
    
    private var uid: String?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.tintColor = .gray3
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        profileImageView.addSubview(overlayerView)
        overlayerView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            
            overlayerView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            overlayerView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            overlayerView.widthAnchor.constraint(equalToConstant: 40),
            overlayerView.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.centerXAnchor.constraint(equalTo: overlayerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: overlayerView.centerYAnchor)
        ])
        
        var constraints = [NSLayoutConstraint]()
        
        
    }
    
    func configure(with user: User) {
        uid = user.uid
        nameLabel.text = user.name
        profileImageView.loadProfileImage(url: user.profileImageUrl) {}
        
        var constraints = [NSLayoutConstraint]()
        
        if user.isBlock {
            // 정지 사용자
            iconView.image = UIImage(systemName: "exclamationmark.circle")
            overlayerView.isHidden = false
        } else if let blockedUserList = UserManager.shared.user.blockedUserList, blockedUserList.contains(user.uid) {
            // 차단 사용자
            iconView.image = UIImage(systemName: "nosign")
            overlayerView.isHidden = false
        } else {
            overlayerView.isHidden = true
        }
    }
}
