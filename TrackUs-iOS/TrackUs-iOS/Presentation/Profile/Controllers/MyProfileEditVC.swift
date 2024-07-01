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
import FirebaseStorage

class MyProfileEditVC: UIViewController, ProfileImageViewDelegate,UITextFieldDelegate, MainButtonEnabledDelegate {
    
    // 선택 이미지
    private var selectImage: UIImage?
    
    private lazy var profileImageView: ProfilePictureInputView = {
        let view = ProfilePictureInputView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.imageView.layer.cornerRadius = 80
        view.imageView.layer.masksToBounds = true
        return view
    }()
    
//    private let nicknameTitleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "닉네임"
//        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//        label.tintColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
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
        //view.addSubview(nicknameTitleLabel)
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
            
//            nicknameTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 26),
//            nicknameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameInputView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
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
        self.selectImage = image
    }
    
    @objc private func saveButtonTapped() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        var user = UserManager.shared.user
        let newNickname = nicknameInputView.getNickname()
        user.name = newNickname
        user.isProfilePublic = self.toggleSwitch.isOn
        
        guard !newNickname.isEmpty else {
            return
        }
        
        // 중복 확인
        checkUser(name: newNickname) { [self] isUnique in
            if !isUnique {
                saveImage(image: selectImage) { url in
                    user.profileImageUrl = url
                    // 사용자 데이터 업데이트
                    UserManager.shared.updateUserData(user: user) { success in
                        if success {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            // 업데이트 실패 처리
                        }
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
    
    // 이미지 저장
    func saveImage(image: UIImage?, completionHandler: @escaping (String?) -> Void) {
        // 이미지 저장 -> url 포함 User 저장
        guard let image = image else { return completionHandler(nil) }
        let uid = User.currentUid
        let ref = Storage.storage().reference().child("profileImages/\(uid)")
        
        // 이미지 비율 줄이기 (용량 감소 목적)
        guard let resizedImage = image.resizeWithWidth(width: 300) else { return }
        // 이미지 포멧 JPEG 변경
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.5) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 storage에 저장
        ref.putData(jpegData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to push image to Storage: \(error)")
                return
            }
            // url 받아오기
            ref.downloadURL { url, error in
                if let error = error{
                    print("Failed to retrieve downloadURL: \(error)")
                    return
                }
                
                // 이미지 url 저장
                guard let url = url else { return }
                ImageCacheManager.shared.setImage(image: image, url: url.absoluteString)
                completionHandler(url.absoluteString)
                return
            }
        }
    }
    
    /// 닉네임 중복 확인
    func checkUser(name: String, completionHandler: @escaping (Bool) -> Void) {
        guard let currentUserId = currentUserId else {
            completionHandler(false)
            return
        }
        
        Firestore.firestore().collection("users")
            .whereField("name", isEqualTo: name)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completionHandler(false)
                    return
                }
                
                // Assuming there's only one document with the specified name
                if let document = querySnapshot?.documents.first {
                    if let userUid = document.data()["uid"] as? String {
                        completionHandler(currentUserId == userUid ? false : true)
                    } else {
                        completionHandler(false)
                    }
                } else {
                    completionHandler(false)
                }
            }
    }
    
    private func fetchUserProfile() {
        let user = UserManager.shared.user
        self.profileImageView.imageView.loadProfileImage(url: user.profileImageUrl, borderWidth: 10) {}
        self.nicknameInputView.textField.text = user.name
        self.checkNicknameValidity(user.name)
        self.toggleSwitch.isOn = user.isProfilePublic
        self.checkSaveButtonValidity()
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
