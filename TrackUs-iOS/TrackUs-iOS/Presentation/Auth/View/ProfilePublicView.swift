//
//  File.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/17/24.
//

import UIKit

// MARK: - 프로필 공개 view
class ProfilePublicView: UIView {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "프로필 공개 여부"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray1
        return label
    }()
    
    private lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .mainBlue
        toggle.isOn = true
        //toggle.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return toggle
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, toggle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAutoLayout()
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAutoLayout()
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func getPublic() -> Bool{
        return toggle.isOn
    }
}
