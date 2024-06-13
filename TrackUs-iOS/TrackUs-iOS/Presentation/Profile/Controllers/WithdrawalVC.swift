//
//  WithdrawalVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

import UIKit
import Firebase

class WithdrawalVC: UIViewController, UITextViewDelegate {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원 탈퇴 안내"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원 탈퇴시 아래 사항을 꼭 확인해 주세요."
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .red
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 14
        paragraphStyle.paragraphSpacing = 8
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(named: "Gray2")!
        ]
        
        let text = """
        1. 개인 정보 및 이용 기록은 모두 삭제되며, 삭제된 계정은 복구할 수 없습니다.
        2. 러닝 데이터를 포함한 모든 운동에 관련된 정보는 따로 저장되지 않으며 즉시 삭제 됩니다.
        """
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = attributedText
        return label
    }()

    
    private let reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원 탈퇴 사유"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let reasonTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(named: "Gray3")?.cgColor
        textView.layer.cornerRadius = 5.0
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.textColor = .gray1
        textView.text = "탈퇴 사유를 작성해주세요."
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()
    
    private let agreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "안내 사항 확인 후 탈퇴에 동의합니다."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private let radioButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: "Gray3")?.cgColor
        button.layer.cornerRadius = 12.5
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mainButton: MainButton = {
        let button = MainButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = "회원탈퇴"
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
        return button
    }()

    
    private var isRadioButtonSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupViews()
        reasonTextView.delegate = self
        
        // 화면 터치 인식 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        self.tabBarController?.tabBar.isHidden = true
    }

    private func setupNavBar() {
        self.navigationItem.title = "회원탈퇴"
        
    let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(reasonTitleLabel)
        contentView.addSubview(reasonTextView)
        contentView.addSubview(agreementLabel)
        contentView.addSubview(radioButton)
        contentView.addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reasonTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 126),
            reasonTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reasonTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            reasonTextView.topAnchor.constraint(equalTo: reasonTitleLabel.bottomAnchor, constant: 10),
            reasonTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reasonTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reasonTextView.heightAnchor.constraint(equalToConstant: 290),
            
            agreementLabel.topAnchor.constraint(equalTo: reasonTextView.bottomAnchor, constant: 20),
            agreementLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            radioButton.centerYAnchor.constraint(equalTo: agreementLabel.centerYAnchor),
            radioButton.leadingAnchor.constraint(equalTo: agreementLabel.trailingAnchor, constant: 10),
            radioButton.widthAnchor.constraint(equalToConstant: 25),
            radioButton.heightAnchor.constraint(equalToConstant: 25),
            radioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            mainButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainButton.heightAnchor.constraint(equalToConstant: 56),
            mainButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: 20),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: mainButton.bottomAnchor, constant: 16)
        ])
    }

    @objc private func radioButtonTapped() {
        isRadioButtonSelected.toggle()
        radioButton.backgroundColor = isRadioButtonSelected ? UIColor(named: "mainBlue") : .clear
        if isRadioButtonSelected {
            radioButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            radioButton.tintColor = .mainBlue
        } else {
            radioButton.setImage(nil, for: .normal)
        }
    }

    @objc private func withdrawalButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Gray1")!,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ]
        let attributedTitle = NSAttributedString(string: "알림", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")

        let messageAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Gray1")!,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        let attributedMessage = NSAttributedString(string: "정말 탈퇴를 진행하시겠습니까?\n트랙어스 서비스의 모든 데이터가 삭제됩니다.", attributes: messageAttributes)
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "탈퇴", style: .destructive) { _ in
            self.deleteUserAccount()
            // 우선 임시로 이거로 함 ㅇㅅㅇ
            print("회원탈퇴 처리")
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true, completion: nil)
    }
    private func deleteUserAccount() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(User.currentUid)
        userRef.delete { error in
            if let error = error {
                //print("Error deleting user document: \(error)")
                return
            }
            
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    //print("Error deleting user account: \(error)")
                    return
                }
                
                do {
                    try Auth.auth().signOut()
                    
                    // 로그인 화면으로 이동
                    let loginVC = LoginVC()
                    UIApplication.shared.windows.first?.rootViewController = loginVC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                    
                } catch let signOutError as NSError {
                    //print("Error signing out: %@", signOutError)
                }
            }
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "Gray2")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "탈퇴 사유를 작성해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
}
