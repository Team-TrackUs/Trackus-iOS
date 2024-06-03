//
//  ChatMessageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 6/3/24.
//

import UIKit

class ChatMessageView: UIView {
    private let message: Message
    private let isMyMessage: Bool
    
    init(message: Message, isMyMessage: Bool) {
        self.message = message
        self.isMyMessage = isMyMessage
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let messageLabel = UILabel()
        messageLabel.text = message.text
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = isMyMessage ? .mainBlue : .gray2
        messageLabel.textColor = isMyMessage ? .white : .black
        messageLabel.layer.cornerRadius = 10
        messageLabel.layer.masksToBounds = true
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        
        if isMyMessage {
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        } else {
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        }
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
    }
}
