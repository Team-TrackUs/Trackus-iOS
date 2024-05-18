//
//  SignUpVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/14/24.
//

import UIKit

class SignUpVC: UIViewController, MainButtonEnabledDelegate {
    
    var currentStep = 0 {
        didSet{
            switch currentStep{
                case 0:
                    nextStepView()
                case 1:
                    nextStepView()
                case 2:
                    nextStepView()
                case 3:
                    nextStepView()
                default:
                    return
            }
        }
    }
    
    var view1 = AgreementInputView()
    var view2 = NicknameInputView()
    var view3 = ProfilePictureInputView()
    var view4 = ProfilePublicView()
    
    // 메인 버튼 하단 위치 제약조건
    var mainButtonBottomConstraint: NSLayoutConstraint!
    
    private lazy var subViews: [UIView] = [view1,view2, view3, view4]
    
    var SignUpSteps: [SignUpStep] = [
        // 약관 동의
        SignUpStep(title: "약관 동의",
                   description: "TrackUs의 원할한 서비스 제공을 위해\n이용 약관의 동의가 필요합니다.",
                   buttonText: "동의하고 가입하기"),
        // 닉네임 설정
        SignUpStep(title: "닉네임 설정",
                   description: "다른 러너들에게 자신을 잘 나타낼 수 있는 닉네임을 설정해주세요.",
                   buttonText: "다음으로"),
        // 프로필 사진 등록
        SignUpStep(title: "프로필 사진 등록",
                   description: "다른 러너들에게 자신을 잘 나타낼 수 있는\n프로필 이미지를 설정해주세요.",
                   buttonText: "다음으로"),
        // 프로필 공개
        SignUpStep(title: "프로필 공개",
                   description: "프로필 공개 상태인 경우 모든 사람이\n러닝 기록과 그룹러닝 참여 내역을 볼 수 있습니다.",
                   buttonText: "TrackUs 시작하기")
    ]
    
    // 상단 프로그래스바
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .mainBlue
        progress.trackTintColor = .gray3
        progress.setProgress(Float(currentStep+1)/Float(SignUpSteps.count), animated: true)
        progress.layer.cornerRadius = 6
        progress.layer.masksToBounds = true
        
        // 높이 설정
        progress.heightAnchor.constraint(equalToConstant: 12).isActive = true
        return progress
    }()
    
    // 제목 label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.black
        label.text = SignUpSteps[currentStep].title
        return label
    }()
    
    // 설명 label
    private lazy var subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // 여러 줄로 표시
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.gray2
        label.text = SignUpSteps[currentStep].description
        return label
    }()
    
    
    // 다음으로 버튼
    private lazy var mainButton: UIButton = {
        let button = MainButton()
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = SignUpSteps[currentStep].buttonText
        button.addTarget(self, action: #selector(buttonTeapped), for: .touchUpInside)
        
        return button
    }()
    
    // 제목, 설명 스택뷰
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        //stackView.distribution = .fillEqually
        //stackView.alignment = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupAutoLayout()
        view1.delegate = self
        view2.delegate = self
        view3.delegate = self
        view4.delegate = self
        
        
        // 키보드 메소드 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - 오토레이아웃 세팅
    private func setupAutoLayout() {
        self.view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
            progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
        
        self.view.addSubview(labelStackView)
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 32),
            labelStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
        subViews[currentStep].translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(subViews[currentStep])
                NSLayoutConstraint.activate([
                    subViews[currentStep].topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 20),
                    subViews[currentStep].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                    subViews[currentStep].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
                ])
//        subView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(subView)
//        NSLayoutConstraint.activate([
//            subView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 20),
//            subView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
//            subView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
//        ])
        mainButtonBottomConstraint = mainButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        self.view.addSubview(mainButton)
        NSLayoutConstraint.activate([
            mainButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mainButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            //bottomStackView.heightAnchor.constraint(equalToConstant: 45),
            mainButtonBottomConstraint
        ])
    }
    
    @objc func buttonTeapped() {
        
        currentStep += 1
        mainButton.isEnabled = false
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 키보드 높이만큼 MainButton의 bottom constraint 조정
            mainButtonBottomConstraint.constant = 15 - keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // 키보드가 사라질 때 MainButton의 위치를 원래대로 복귀
        mainButtonBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 메인 버튼 활성화
    func MainButtonDidChangeEnabled(_ isEnabled: Bool) {
        mainButton.isEnabled = isEnabled
        UIView.animate(withDuration: 0.3) {
            self.mainButton.layoutIfNeeded()
        }
    }
    
    // 바뀐 뷰에 맞게 내용 수정
    func nextStepView(){
        // 다음 뷰로 수정
        subViews[currentStep-1].removeFromSuperview()
        let nextView = subViews[currentStep]
        nextView.frame = self.view.bounds
        self.view.addSubview(nextView)
        subViews[currentStep].translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(subViews[currentStep])
        NSLayoutConstraint.activate([
            subViews[currentStep].topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 20),
            subViews[currentStep].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            subViews[currentStep].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
        
        
        progressBar.setProgress(Float(currentStep+1)/Float(SignUpSteps.count), animated: true)
        titleLabel.text = SignUpSteps[currentStep].title
        subLabel.text = SignUpSteps[currentStep].description
        mainButton.setTitle(SignUpSteps[currentStep].buttonText, for: .normal)
    }
    
    deinit {
        // 옵저버 제거
        NotificationCenter.default.removeObserver(self)
    }
}


struct SignUpStep {
    let title: String
    let description: String
    let buttonText: String
}


