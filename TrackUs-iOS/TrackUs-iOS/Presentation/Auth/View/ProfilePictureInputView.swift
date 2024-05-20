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
        imageView.tintColor = .gray3
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
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
        // 이미지 뷰 설정
        //imageView.layer.cornerRadius = frame.size.width / 2
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        // 탭 제스처 인식기 추가
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc private func handleTap() {
        let actionSheet = UIAlertController(title: "프로필 사진 설정", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "앨범에서 사진 선택", style: .default, handler: { _ in
            self.showImagePicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "기본 이미지 설정", style: .destructive, handler: { _ in
            self.imageView.image = nil // 기본 이미지로 설정
            self.delegate?.didChooseImage(nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 현재 뷰 컨트롤러를 찾아서 액션 시트를 표시합니다.
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
            imageView.image = image
            delegate?.didChooseImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 현재 UIView가 속한 UIViewController를 찾는 메소드
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
