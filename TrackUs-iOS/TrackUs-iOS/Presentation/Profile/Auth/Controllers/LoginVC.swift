//
//  LoginVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//

import UIKit
import Firebase

final class LoginVC: UIViewController {
    
    private lazy var icon: UIImageView = {
        let image = UIImage(named: "trackus_icon")?.resize(width: 90, height: 73)
        //image?.size.width = 30
        return UIImageView(image: image)
    }()
    
    // MARK: - 로그인 화면 문구들
    private lazy var appTitle1Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // 여러 줄로 표시
        let text = "오늘부터\n내 주변 러너들과\n함께 뛰어요!"
        let attributedText = NSMutableAttributedString(string: text)
        
        // "오늘부터"
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray1, range: NSRange(location: 0, length: 4))
        // "내 주변 러너들"
        attributedText.addAttribute(.foregroundColor, value: UIColor.mainBlue, range: NSRange(location: 5, length: 8))
        // "과"
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray1, range: NSRange(location: 13, length: 1))
        // "함께"
        attributedText.addAttribute(.foregroundColor, value: UIColor.mainBlue, range: NSRange(location: 15, length: 2))
        // "뛰어요!"
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray1, range: NSRange(location: 17, length: 5))
        // UILabel에 속성 텍스트 설정
        label.attributedText = attributedText
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    // 로그인 버튼 상단 문구
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // 여러 줄로 표시
        label.textAlignment = .center
        label.text = "TrackUs를 통해 러닝 메이트를 모집하고\n함께 러닝을 즐겨보세요."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.gray1
        return label
    }()
    
    // MARK: - 테스트 로그인 버튼
    private lazy var testLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray2
        // apple 로고 추가
        
        button.setTitle("Test Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.systemBackground, for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(testLoginButtonTapped), for: .touchUpInside)
        
        // 높이 제약
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    // MARK: - 테스트 로그인 버튼 실행 함수
    @objc func testLoginButtonTapped() {
        Auth.auth().signIn(withEmail: "test@test.com",
                           password: "asdfasdf12")
    }
    
    // MARK: - Apple 로그인 버튼
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .label
        // apple 로고 추가
        let LogoImage = UIImage(systemName: "applelogo")
        button.setImage(LogoImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .systemBackground
        button.imageView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10) // 로고와 문구 사이의 간격 조절
        
        button.setTitle("Apple로 시작하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.systemBackground, for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        
        // 높이 제약
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    // MARK: - Kakao 로그인 버튼
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 1, green: 0.8935882449, blue: 0, alpha: 1)
        // apple 로고 추가
        if let LogoImage = UIImage(named: "kakao_icon")?.resize(width: 16, height: 16){
            button.setImage(LogoImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.tintColor = .white
            button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10) // 로고와 문구 사이의 간격 조절
        }
        
        button.setTitle("카카오톡으로 시작하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0), for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        
        // 높이 제약
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    
    // 배경용 그라데이션 뷰
    private lazy var gradientView: UIView = {
        let gradientView = GradientBackgroundView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        return gradientView
    }()
    
    // 센터 로고, 문구 스택뷰
    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [icon, appTitle1Label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        
        //stackView.distribution = .fillEqually
        //stackView.alignment = .fill
        return stackView
    }()
    
    // 소셜 로그인 버튼 스택뷰
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ testLoginButton, appleLoginButton, kakaoLoginButton])
        //let stackView = UIStackView(arrangedSubviews: [ appleLoginButton, kakaoLoginButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .white
        setupAutoLayout()
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
        
        self.view.addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.view.addSubview(titleStackView)
        NSLayoutConstraint.activate([
            titleStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -80),
            titleStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        
        ])
        self.view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            //bottomStackView.heightAnchor.constraint(equalToConstant: 45),
            buttonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        self.view.addSubview(subLabel)
        NSLayoutConstraint.activate([
            subLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            subLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            subLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -10)
        ])
    }
    
    // MARK: - Apple 로그인 버튼 실행 함수
    @objc func appleLoginButtonTapped() {
        AuthService.shared.handleAppleLogin()
    }
    
    // MARK: - Kakao 로그인 버튼 실행 함수
    @objc func kakaoLoginButtonTapped() {
        AuthService.shared.handleKakaoLogin()
    }
}

/// 배경 그라데이션
class GradientBackgroundView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.mainBlue.withAlphaComponent(0.5).cgColor, UIColor.systemBackground.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.6)
        gradientLayer.frame = bounds
    }
}
