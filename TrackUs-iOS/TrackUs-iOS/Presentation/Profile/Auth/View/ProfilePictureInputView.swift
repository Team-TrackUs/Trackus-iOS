//
//  File.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/17/24.
//

import UIKit

// 프로토콜을 정의하여 이미지 선택이 완료되었을 때의 동작을 위임합니다.
protocol ProfileImageViewDelegate: AnyObject {
    func didChooseImage(_ image: UIImage?)
}

// MARK: - 프로필 이미지 view
class ProfilePictureInputView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: ProfileImageViewDelegate?
    lazy var imageView: UIImageView = {
        let image = UIImage(systemName: "person.crop.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 160).isActive = true
        imageView.tintColor = .gray3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    private lazy var cameraIcon: UIImageView = {
        let image = UIImage(systemName: "camera.circle.fill")
        let imageView = UIImageView(image: image)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.tintColor = .gray3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemBackground
        
        // 회색 테두리 추가
        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        imageView.layer.borderWidth = 3
        return imageView
    }()
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAutoLayout()
    }
    // MARK: - Setup AutoLayout
    private func setupAutoLayout() {
        addSubview(imageView)
        addSubview(cameraIcon)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            cameraIcon.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 50),
            cameraIcon.centerXAnchor.constraint(equalTo: imageView.centerXAnchor, constant: 50)
        ])
        
        // 탭 제스처 추가
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func handleTap() {
        let actionSheet = UIAlertController(title: "프로필 사진 설정", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "앨범에서 사진 선택", style: .default, handler: { _ in
            self.showImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "기본 이미지 설정", style: .destructive, handler: { _ in
            self.imageView.image = UIImage(systemName: "person.crop.circle.fill") // 기본 이미지로 설정
            self.imageView.layer.borderWidth = 0
            self.delegate?.didChooseImage(nil)
            
            self.cameraIcon.isHidden = false
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 현재 뷰 컨트롤러를 찾아서 액션 시트를 표시
        if let viewController = findViewController() {
            viewController.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        if let viewController = findViewController() {
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // UIImagePickerControllerDelegate 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            cameraIcon.isHidden = true
            imageView.image = image
            imageView.layer.cornerRadius = imageView.frame.height / 2
            imageView.layer.masksToBounds = true
            
            // 회색 테두리 추가
            imageView.layer.borderColor = UIColor.gray3.cgColor
            imageView.layer.borderWidth = 1
            delegate?.didChooseImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
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
