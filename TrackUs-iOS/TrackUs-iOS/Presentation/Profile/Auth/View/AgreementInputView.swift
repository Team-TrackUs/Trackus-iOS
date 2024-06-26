//
//  AgreementInputView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/16/24.
//

import UIKit
import SafariServices

// MARK: - 약관 동의 view
class AgreementInputView: UIView {
    
    // 이용 약관 페이지 url -> 이후 수정
    private let urls = [
        // 서비스 이용 약관 동의
        "https://spice-game-f38.notion.site/268a6acbcd2144569d7164abaebbd6b3?pvs=4",
        // 개인정보 처리방침 동의
        "https://spice-game-f38.notion.site/cf7cb34cd1144ff28abf92248061906e?pvs=4",
        //위처정보 서비스 이용약관 동의
        "https://spice-game-f38.notion.site/cc9f6755c6f04af39a396f7976c61661?pvs=4"
    ]
    
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
    
    // 전체 동의하기 버튼
    private lazy var allAgreeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(" 모두 동의합니다.", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.gray1, for: .normal)
        
        let LogoImage = UIImage(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
        button.setImage(LogoImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = isAllSelected ? .mainBlue : .gray3
        
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
    
    // 약관별 버튼
    private lazy var termsButtons: [UIButton] = {
        let buttonTitles = [
            " 만 14세 이상입니다",
            " 서비스 이용약관 동의",
            " 개인정보 처리방침 동의",
            " 위치정보 서비스 이용약관 동의"
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
            
            button.addTarget(self, action: #selector(termsButtonTapped(sender:)), for: .touchUpInside)
            return button
        }
        return buttons
    }()
    
    // 약관별 버튼
    private lazy var termsViewButtons: [UIButton] = {
        let titles = ["보기", "보기", "보기"]
        return titles.map { title in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(.gray2, for: .normal)
            button.addTarget(self, action: #selector(termsViewButtonTapped(sender:)), for: .touchUpInside)
            
            // 밑줄 추가
            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
            button.setAttributedTitle(attributedString, for: .normal)
            
            return button
        }
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
    
    private lazy var viewButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        
        //stackView.distribution = .fillEqually
        stackView.alignment = .trailing
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
        self.addSubview(viewButtonStackView)
        
        buttonStackView.addArrangedSubview(allAgreeButton)
        buttonStackView.addArrangedSubview(lineView)
        termsButtons.forEach { button in
            buttonStackView.addArrangedSubview(button)
        }
        termsViewButtons.forEach { button in
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            viewButtonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            
            viewButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewButtonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
    
    // 약관 상세페이지 보기
    @objc private func termsViewButtonTapped(sender: UIButton) {
        switch sender {
            case termsViewButtons[0]:
                presentSheet(url: urls[0])
            case termsViewButtons[1]:
                presentSheet(url: urls[1])
            case termsViewButtons[2]:
                presentSheet(url: urls[2])
            default:
                return
        }
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
    
    private func presentSheet(url: String) {
        guard let viewController = findViewController() else { return }
        if let url = URL(string: url) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .pageSheet
            viewController.present(safariVC, animated: true, completion: nil)
        }
    }
    
    // UIView가 속한 UIViewController를 찾기
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
