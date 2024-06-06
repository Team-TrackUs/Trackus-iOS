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
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.layer.cornerRadius = 60 / 2
        imageView.backgroundColor = .gray2
        imageView.tintColor = .gray3
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
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(OwnerCrownView)
        
        contentView.addSubview(stack)
        stack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func configure(uid: String, isOwner: Bool) {
        PostService().fetchMembers(uid: uid) { name, url in
            
            // 이미지 존재 확인 없으면 기본 프로필
            if url == "" {
                self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
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
