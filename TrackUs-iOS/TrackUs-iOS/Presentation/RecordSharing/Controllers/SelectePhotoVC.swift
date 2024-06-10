//
//  SelectePhotoVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/5/24.
//

import UIKit
import AVFoundation

final class SelectePhotoVC: UIViewController {
    // MARK: - Properties
    // Cpatrue Session
    private var session: AVCaptureSession?
    // Photo Output
    private var output: AVCapturePhotoOutput!
    // Video Preview
    private let previewLayer = AVCaptureVideoPreviewLayer()
    // Shtter Button
    public var onCompleted: (UIImage?) -> Void = { (image) in }
    
    
    private let cameraPreview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        
        let takePhotoButton = UIButton()
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        takePhotoButton.heightAnchor.constraint(equalTo: takePhotoButton.widthAnchor).isActive = true
        takePhotoButton.layer.borderWidth = 4
        var image = UIImage(systemName: "camera")?.resizeWithWidth(width: 40)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        takePhotoButton.setImage(image, for: .normal)
        takePhotoButton.layer.cornerRadius = 40
        takePhotoButton.layer.borderColor = UIColor.gray.cgColor
        takePhotoButton.clipsToBounds = true
        takePhotoButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        [UIView(), takePhotoButton, UIView()].forEach { sv.addArrangedSubview($0) }
        
        return sv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraint()
        setupNavBar()        
        checkCameraPermissions()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraPreview.bounds
        cameraPreview.layer.addSublayer(previewLayer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonEnabled()
        checkCameraPermissions()
    }
    
    // MARK: - Helpers
    
    private func setConstraint() {
        view.addSubview(cameraPreview)
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            cameraPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraPreview.heightAnchor.constraint(equalToConstant: view.frame.height * 0.5),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStack.topAnchor.constraint(equalTo: cameraPreview.bottomAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupNavBar() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "사진 촬영"
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: closeButton)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 16).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        navigationItem.leftBarButtonItem = menuBarItem
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    self.dissmossView()
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }            
            break
        case .authorized:
            DispatchQueue.main.async {
                self.setUpCamera()
            }
        default:
            showSettingAlert()
            break
        }
    }
    
    private func showSettingAlert() {
        let alert = UIAlertController(title: "카메라 권한", message: "설정에서 카메라 권한을 허용 해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: { _ in
            self.dissmossView()
        }))
        alert.addAction(UIAlertAction(title: "설정하러 가기", style: .default, handler: goToAppSettings))
        
        self.present(alert, animated: true)
    }
    
    private func goToAppSettings(_ sender: UIAlertAction) {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    private func dissmossView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession() // 캡처세션 생성
        output = AVCapturePhotoOutput() // 데이터를 보내는 출려대상을 촬영떄마다 초기화
     
        // 기본 비디오장치
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                // 프리뷰레이어에 세션추가
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning() // 세션시작
                self.session = session
            }
            catch {
                print(error)
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func didTapTakePhoto() {
        buttonDisabled()
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
      }
    
    func buttonEnabled() {
        buttonStack.isUserInteractionEnabled = true
    }
    
    func buttonDisabled() {
        buttonStack.isUserInteractionEnabled = false
    }
}

extension SelectePhotoVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        session?.stopRunning()
        onCompleted(image)
    }
}
