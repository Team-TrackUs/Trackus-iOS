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
    var session: AVCaptureSession?
    // Photo Output
    var output: AVCapturePhotoOutput!
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    // Shtter Button
    
    
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
//        checkCameraPermissions()
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
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    func setUpCamera() {
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
    
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func didTapTakePhoto() {
          output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
      }
}

extension SelectePhotoVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        session?.stopRunning()
        self.navigationController?.pushViewController(PhotoEditVC(), animated: true)
    }
}
