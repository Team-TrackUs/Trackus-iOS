//
//  AgreementInputView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/16/24.
//

import UIKit

// MARK: - 약관 동의 view
class AgreementInputView: UIView {
    
    var delegate: MainButtonEnabledDelegate?
    
    private lazy var isOver14Selected = false {
        didSet{
            buttonImageChange(button: termsButtons[0], check: isOver14Selected)
        }
    }
    private lazy var isUserSelected = false {
        didSet{
            buttonImageChange(button: termsButtons[1], check: isUserSelected)
        }
    }
    private lazy var isPrivacyPolicySelected = false {
        didSet{
            buttonImageChange(button: termsButtons[2], check: isPrivacyPolicySelected)
        }
    }
    private lazy var isLocationTermsSelected = false {
        didSet{
            buttonImageChange(button: termsButtons[3], check: isLocationTermsSelected)
        }
    }
    
    private var isAllSelected: Bool = false {
        didSet{
            delegate?.MainButtonDidChangeEnabled(isAllSelected)
        }
    }
    
    private lazy var allAgreeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("모두 동의합니다.", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.gray1, for: .normal)
        
        let LogoImage = UIImage(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
        button.setImage(LogoImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = isAllSelected ? .mainBlue : .gray3
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        button.addTarget(self, action: #selector(allAgreeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 구분선
    private lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray3
        return view
    }()
    
    private lazy var termsButtons: [UIButton] = {
        let buttonTitles = [
            "만 14세 이상입니다",
            "서비스 이용약관 동의",
            "개인정보 처리방침 동의",
            "위치정보 서비스 이용약관 동의"
        ]
        let buttons = buttonTitles.map { title in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(.gray1, for: .normal)
            
            let LogoImage = UIImage(systemName: "circle")
            button.setImage(LogoImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.tintColor = .gray3
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            
            button.addTarget(self, action: #selector(termsButtonTapped(sender:)), for: .touchUpInside)
            return button
        }
        return buttons
    }()
    
    
    // 제목, 설명 스택뷰
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        
        //stackView.distribution = .fillEqually
        stackView.alignment = .leading
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
        self.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(allAgreeButton)
        buttonStackView.addArrangedSubview(lineView)
        termsButtons.forEach { button in
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // 구분선 크기 설정
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor)
        ])
    }
    
    @objc func allAgreeButtonTapped() {
        if !isAllSelected {
            isPrivacyPolicySelected = true
            isUserSelected = true
            isLocationTermsSelected = true
            isOver14Selected = true
            isAllSelected.toggle()
        } else {
            // 선택 해제 시 모든 선택사항 초기화
            isPrivacyPolicySelected = false
            isUserSelected = false
            isLocationTermsSelected = false
            isOver14Selected = false
            isAllSelected.toggle()
        }
        delegate?.MainButtonDidChangeEnabled(isAllSelected)
        let imageName = isAllSelected ? "checkmark.circle.fill" : "circle"
        let image = UIImage(systemName: imageName)
        allAgreeButton.setImage(image, for: .normal)
        allAgreeButton.imageView?.tintColor = isAllSelected ? .mainBlue : .gray3
    }
    
    @objc private func termsButtonTapped(sender: UIButton) {
        switch sender {
            case termsButtons[0]:
                isOver14Selected.toggle()
                allButtonImageChange()
            case termsButtons[1]:
                isUserSelected.toggle()
                allButtonImageChange()
            case termsButtons[2]:
                isPrivacyPolicySelected.toggle()
                allButtonImageChange()
            case termsButtons[3]:
                isLocationTermsSelected.toggle()
                allButtonImageChange()
            default:
                return
        }
    }
    
    func allButtonImageChange() {
        isAllSelected = isPrivacyPolicySelected && isUserSelected && isLocationTermsSelected && isOver14Selected
        
        let imageName = isAllSelected ? "checkmark.circle.fill" : "circle"
        let image = UIImage(systemName: imageName)
        allAgreeButton.setImage(image, for: .normal)
        allAgreeButton.imageView?.tintColor = isAllSelected ? .mainBlue : .gray3
    }
    
    func buttonImageChange(button: UIButton, check: Bool) -> Void {
        let imageName = check ? "checkmark.circle.fill" : "circle"
        let image = UIImage(systemName: imageName)
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = check ? .mainBlue : .gray3
    }
}
