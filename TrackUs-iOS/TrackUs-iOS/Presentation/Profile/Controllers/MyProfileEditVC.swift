//
//  MyProfileEditVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

import UIKit
import Firebase
import FirebaseStorage

class MyProfileEditVC: UIViewController, ProfileImageViewDelegate {
    
    private lazy var profileImageView: ProfilePictureInputView = {
        let view = ProfilePictureInputView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.imageView.layer.cornerRadius = 80
        view.imageView.layer.masksToBounds = true
        return view
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
        textField.placeholder = "닉네임을 입력하세요"
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
    
    private let saveButton: MainButton = {
        let button = MainButton()
        button.title = "수정 완료"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        view.backgroundColor = .white
        
        hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        
        fetchUserProfile()
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
            profileImageView.widthAnchor.constraint(equalToConstant: 160),
            profileImageView.heightAnchor.constraint(equalToConstant: 160),
            
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
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    func didChooseImage(_ image: UIImage?) {
            guard let selectedImage = image else {
                return
            }
            profileImageView.imageView.image = selectedImage
        }
        
        @objc private func saveButtonTapped() {
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            
            let newNickname = nicknameTextField.text ?? ""
            UserManager.shared.user.name = newNickname
            
            let isProfilePublic = toggleSwitch.isOn
            UserManager.shared.user.isProfilePublic = isProfilePublic
            
            if let profileImage = profileImageView.imageView.image {
                let imageUrl = "profileImages/\(currentUser.uid)"
                ImageCacheManager.shared.setImage(image: profileImage, url: imageUrl)
                UserManager.shared.user.profileImageUrl = imageUrl
                updateUserData(currentUser.uid)
            } else {
                updateUserData(currentUser.uid)
            }
        }
        
        private func updateUserData(_ uid: String) {
            UserManager.shared.updateUserData(uid: uid) { success in
                if success {
                    //print("User data updated successfully")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    //print("Failed to update user data")
                }
            }
        }
        
        private func fetchUserProfile() {
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(currentUser.uid)
            
            userRef.getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                
                let data = document.data()
                if let profileImageUrl = data?["profileImageUrl"] as? String {
                    self.profileImageView.imageView.loadImage(url: profileImageUrl)
                } else {
                    self.profileImageView.imageView.image = UIImage(systemName: "person.crop.circle.fill")
                    self.profileImageView.imageView.tintColor = .gray3
                }
                
                if let userName = data?["name"] as? String {
                    self.nicknameTextField.text = userName
                }
                
                if let isProfilePublic = data?["isProfilePublic"] as? Bool {
                    self.toggleSwitch.isOn = isProfilePublic
                }
            }
        }
    }
