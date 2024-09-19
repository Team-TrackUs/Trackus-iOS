//
//  MainButton.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/15/24.
//

import UIKit

/// MainButton - 기본 색상 mainblue
/// 색상 변경 buttonColor 변경
/// isEnabled : 활성화 여부
class MainButton: UIButton, MainButtonEnabledDelegate {
    var buttonColor: UIColor = .mainBlue
    
    var title: String = "다음으로"{
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    override var isEnabled: Bool{
        didSet {
            backgroundColor = isEnabled ? buttonColor : .gray3
            setTitleColor(isEnabled ? .white : .gray2, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureButton()
    }
    
    private func configureButton() {
        // 버튼의 공통적인 스타일 및 설정을 정의합니다.
        self.layer.cornerRadius = 28
        self.layer.masksToBounds = true
        self.backgroundColor = buttonColor
        self.setTitleColor(.white, for: .normal)
        
        //self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    // 메인버튼 활성화 여부
    func MainButtonDidChangeEnabled(_ isEnabeled: Bool) {
        self.isEnabled = isEnabeled
    }
}

protocol MainButtonEnabledDelegate: AnyObject {
    func MainButtonDidChangeEnabled(_ isEnabeled: Bool)
}
