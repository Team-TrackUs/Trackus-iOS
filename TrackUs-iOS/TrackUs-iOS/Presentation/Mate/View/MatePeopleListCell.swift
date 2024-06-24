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
    private var currentUID: String?
    var isUnknown: Bool = false // 탈퇴회원인지
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.layer.cornerRadius = 60 / 2
        imageView.tintColor = .gray3
        imageView.layer.borderColor = UIColor.gray3.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ownerCrownView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        imageView.image = UIImage(named: "crown_icon")
        imageView.isHidden = true
        return imageView
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let xmarkView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "profileblock_icon")?.withTintColor(.white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        nameLabel.text = nil
        ownerCrownView.isHidden = true
        overlayView.isHidden = true
        xmarkView.isHidden = true
        currentUID = nil
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        profileImageView.addSubview(overlayView)
        overlayView.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        overlayView.isHidden = true
        
        overlayView.addSubview(xmarkView)
        xmarkView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        xmarkView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        xmarkView.isHidden = true
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(ownerCrownView)
        
        contentView.addSubview(stack)
        stack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func configure(uid: String, isOwner: Bool) {
        currentUID = uid
        
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
        profileImageView.layer.borderWidth = 4
        nameLabel.text = "탈퇴회원"
        nameLabel.textColor = .gray2
        ownerCrownView.isHidden = true
        overlayView.isHidden = true
        xmarkView.isHidden = true
        
        isUnknown = true
        
        PostService().fetchMembers(uid: uid) { [weak self] name, url in
            guard let self = self, self.currentUID == uid else { return }
            guard let name = name, let url = url else {
                // 데이터가 없는 경우 기본 설정 유지
                self.ownerCrownView.isHidden = !isOwner
                return
            }
            
            DispatchQueue.main.async {
                if url.isEmpty {
                    self.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
                    self.profileImageView.layer.borderWidth = 4
                } else {
                    self.profileImageView.loadImage(url: url)
                    self.profileImageView.layer.borderWidth = 1
                }
                
                if name.isEmpty {
                    self.nameLabel.text = "탈퇴회원"
                } else {
                    // 이름이 7글자 이상이면 줄임표 표시
                    self.nameLabel.text = name.count > 7 ? "\(name.prefix(6)).." : name
                }
                
                self.nameLabel.textColor = (User.currentUid == uid) ? .black : .gray2
                self.ownerCrownView.isHidden = !isOwner
                
                // 차단한 사용자인지 확인
                self.overlayView.isHidden = !UserManager.shared.user.blockList.contains(uid)
                self.xmarkView.isHidden = self.overlayView.isHidden
                
                self.isUnknown = false
            }
        }
    }
}
