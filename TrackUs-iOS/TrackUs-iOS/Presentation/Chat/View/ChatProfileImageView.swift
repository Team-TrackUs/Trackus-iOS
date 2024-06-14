//
//  ChatUserImageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/30/24.
//

import UIKit

class ChatProfileImageView: UIView {
    
    var users: [String: User] = ChatRoomManager.shared.userInfo
    
    func configure(with members: [String]) {
        // Remove all subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        switch members.count {
            case 0:
                addProfileImageView(url: nil, size: 50)
            case 1:
                addProfileImageView(url: users[members[0]]?.profileImageUrl, size: 50)
            case 2:
                let imageView1 = addProfileImageView(url: users[members[0]]?.profileImageUrl, size: 32)
                imageView1.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView1.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                
                let imageView2 = addProfileImageView(url: users[members[1]]?.profileImageUrl, size: 32)
                imageView2.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                imageView2.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            case 3:
                let imageView1 = addProfileImageView(url: users[members[0]]?.profileImageUrl, size: 25)
                imageView1.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView1.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                
                let imageView2 = addProfileImageView(url: users[members[1]]?.profileImageUrl, size: 25)
                imageView2.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView2.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                
                let imageView3 = addProfileImageView(url: users[members[2]]?.profileImageUrl, size: 25)
                imageView3.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                imageView3.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            default:
                let imageView1 = addProfileImageView(url: users[members[0]]?.profileImageUrl, size: 25)
                imageView1.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView1.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                
                let imageView2 = addProfileImageView(url: users[members[1]]?.profileImageUrl, size: 25)
                imageView2.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                imageView2.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                let imageView3 = addProfileImageView(url: users[members[2]]?.profileImageUrl, size: 25)
                imageView3.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                imageView3.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                
                let imageView4 = addProfileImageView(url: users[members[3]]?.profileImageUrl, size: 25)
                imageView4.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                imageView4.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
    }
    
    @discardableResult
    private func addProfileImageView(url: String?, size: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = size / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray3
        imageView.loadProfileImage(url: url) {}
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        return imageView
    }
}
