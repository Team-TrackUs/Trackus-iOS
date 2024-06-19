//
//  MyProfileEditVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

//
//  MyProfileEditVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

import UIKit
import Firebase

class MyProfileEditVC: UIViewController, ProfileImageViewDelegate,UITextFieldDelegate, MainButtonEnabledDelegate {
    
    private let defaultProfileImage = UIImage(systemName: "person.crop.circle.fill")
    
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
    
    private let nicknameInputView: NicknameInputView = {
        let view = NicknameInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var currentUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupViews()
        view.backgroundColor = .white
        
        fetchUserProfile()
        
        // 화면 터치 인식 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        nicknameInputView.delegate = self
        nicknameInputView.textField.delegate = self
        
        currentUserId = Auth.auth().currentUser?.uid
    }
    
    private func setupNavBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.title = "프로필 변경"
        self.navigationItem.setHidesBackButton(false, animated:true)
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated:true)
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(nicknameTitleLabel)
        view.addSubview(nicknameInputView)
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
            
            nicknameInputView.topAnchor.constraint(equalTo: nicknameTitleLabel.bottomAnchor, constant: 20),
            nicknameInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nicknameInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userRelatedTitleLabel.topAnchor.constraint(equalTo: nicknameInputView.bottomAnchor, constant: 38),
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
        profileImageView.imageView.image = image ?? defaultProfileImage
    }
    
    @objc private func saveButtonTapped() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let newNickname = nicknameInputView.getNickname()
        
        guard !newNickname.isEmpty else {
            return
        }
        
        // 중복 확인
        checkUser(name: newNickname) { isUnique in
            if isUnique {
                UserManager.shared.user.name = newNickname
                
                let isProfilePublic = self.toggleSwitch.isOn
                UserManager.shared.user.isProfilePublic = isProfilePublic
                
                // 이미지가 변경되었는지 확인
                if let profileImage = self.profileImageView.imageView.image, !self.isDefaultImage(profileImage) {
                    let imageUrl = "profileImages/\(currentUser.uid)"
                    ImageCacheManager.shared.setImage(image: profileImage, url: imageUrl)
                    UserManager.shared.user.profileImageUrl = imageUrl
                } else {
                    UserManager.shared.user.profileImageUrl = nil
                }
                
                // 사용자 데이터 업데이트
                UserManager.shared.updateUserData(uid: currentUser.uid) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        // 업데이트 실패 처리
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "닉네임 중복", message: "이미 등록된 닉네임입니다.\n다시 입력해주시기 바랍니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.saveButton.isEnabled = true
                }
            }
        }
    }
    
    /// 닉네임 중복 확인
    func checkUser(name: String, completionHandler: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("name", isEqualTo: name)
            .whereField("uid", isEqualTo: currentUserId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error checking user: \(error.localizedDescription)")
                    completionHandler(false)
                    return
                }
                // 현재 사용자꺼는 중복 처리 x
                if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
    }
    
    private func isDefaultImage(_ image: UIImage) -> Bool {
        return image == defaultProfileImage
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
                self.nicknameInputView.textField.text = userName
                
                self.checkNicknameValidity(userName)
            }
            
            if let isProfilePublic = data?["isProfilePublic"] as? Bool {
                self.toggleSwitch.isOn = isProfilePublic
            }
            self.checkSaveButtonValidity()
        }
    }
    
    private func checkNicknameValidity(_ nickname: String) {
        nicknameInputView.isError = !isValidNickname(nickname)
        checkSaveButtonValidity()
    }

    private func isValidNickname(_ nickname: String) -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!?@#$%^&*()_+=-<>,.;|/:[]{}")
        return nickname.count >= 2 && nickname.count <= 10 && !nickname.contains(" ") && nickname.rangeOfCharacter(from: specialCharacters) == nil
    }
    
    private func checkSaveButtonValidity() {
        let isNicknameValid = isValidNickname(nicknameInputView.getNickname())
        saveButton.isEnabled = isNicknameValid
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        checkNicknameValidity(currentText)
        return true
    }

    func MainButtonDidChangeEnabled(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }
}
