//
//  RefreshView.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/30/24.
//

import UIKit

class RefreshView: UIView {
    
    // MARK: - Properties
    
    private let text = ["\u{1F6A9} 나만의 페이스로, 나만의 피니쉬라인까지.", "\u{1F642} 나만의 런웨이에서 뛰어보세요.", "\u{1F45F} 한 걸음씩, 하루를 시작해요.", "\u{1F3C3}\u{1F3C3} 목표를 향해 함께 뛰어요!", "\u{1F604} 달리는 동안 모든 걸 잊어봐요.", "\u{1F3C3} 트랙어스와 함께", "\u{1F60A} 오늘의 런을 즐겨봐요."]
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
    func configureUI() {
        backgroundColor = UIColor.clear
        
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    func updateText() {
        let randomIndex = Int.random(in: 0..<text.count)
        label.text = text[randomIndex]
    }
}
