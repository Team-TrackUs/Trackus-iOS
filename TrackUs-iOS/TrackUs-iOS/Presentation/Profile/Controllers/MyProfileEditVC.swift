//
//  MyProfileEditVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

import UIKit

class MyProfileEditVC: UIViewController {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_person_icon")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    class CustomTextField: UITextField {
        var textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: textInsets)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: textInsets)
        }

        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: textInsets)
        }
    }

    private let textFieldHeight: CGFloat = 47
    
    private let nicknameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "TrackUs"
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor(named: "Gray1")
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor(named: "Gray3")?.cgColor
        textField.layer.borderWidth = 1.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.textInsets = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 16)
        
        return textField
    }()
    
    private let userRelatedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "사용자 관련"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let publicProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 공개 여부"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "Gray1")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.onTintColor = UIColor(named: "MainBlue")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정 완료", for: .normal)
        button.backgroundColor = UIColor(named: "MainBlue")
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        view.backgroundColor = .white
        
        hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setupNavBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = "프로필 변경"
        self.navigationItem.setHidesBackButton(false, animated:true)
        
    }
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nicknameTitleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(userRelatedTitleLabel)
        view.addSubview(publicProfileLabel)
        view.addSubview(toggleSwitch)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nicknameTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 26),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameTextField.topAnchor.constraint(equalTo: nicknameTitleLabel.bottomAnchor, constant: 20),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userRelatedTitleLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 38),
            userRelatedTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            publicProfileLabel.topAnchor.constraint(equalTo: userRelatedTitleLabel.bottomAnchor, constant: 20),
            publicProfileLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: publicProfileLabel.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
