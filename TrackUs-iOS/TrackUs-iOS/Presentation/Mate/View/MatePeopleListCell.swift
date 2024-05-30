//
//  MatePeopleListCell.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/20/24.
//

import UIKit

class MatePeopleListCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "HorizontalListCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 61).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 61).isActive = true
        imageView.layer.cornerRadius = 61 / 2
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let OwnerCrownView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.image = UIImage(named: "crown_icon")
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
    func configureUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        contentView.addSubview(OwnerCrownView)
        OwnerCrownView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 1).isActive = true
        OwnerCrownView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
    }
    
    func configure(uid: String, isOwner: Bool) {
        PostService().fetchMembers(uid: uid) { name, url in
            
            // 이미지 존재 확인 없으면 기본 프로필
            if url == "" {
                self.profileImageView.image = UIImage(named: "profile_img")
            } else {
                self.profileImageView.loadImage(url: url ?? "")
            }
            
            // 이름의 길이 확인 7글자 이상이면 .. 표시
            if name?.count ?? 1 > 7 {
                self.nameLabel.text = "\(String(describing: name?.prefix(6))).."
            } else {
                self.nameLabel.text = name
            }
            
            // 글쓴이 확인 왕관표시
            if isOwner {
                self.OwnerCrownView.isHidden = false
            } else {
                self.OwnerCrownView.isHidden = true
            }
        }
    }
}
