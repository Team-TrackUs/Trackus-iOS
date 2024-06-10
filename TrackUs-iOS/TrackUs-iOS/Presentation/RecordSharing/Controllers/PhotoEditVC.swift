//
//  PhotoEditVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/5/24.
//

import UIKit
import Photos

final class PhotoEditVC: UIViewController {
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            updateImage()
        }
    }
    var runModel: Running? {
        didSet {
            // 이곳에서 컬렉션뷰 리로드
        }
    }
    
    private lazy var photoPreview: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = image
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["러닝데이터", "스티커"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        control.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        control.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)        
        return control
    }()
    
    private let colVC1 = DataCollectionVC(collectionViewLayout: UICollectionViewFlowLayout())
    private let colVC2 = StickerCollectionVC(collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var pages = [colVC1, colVC2]
    
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.backgroundColor = .black
        return vc
    }()
    
    var pageIndex = 0 {
        didSet {
            segmentedControl.selectedSegmentIndex = pageIndex
            let willAppearVC = [pages[pageIndex]]
            let direction: UIPageViewController.NavigationDirection = pageIndex == 0 ? .reverse : .forward
            pageViewController.setViewControllers(willAppearVC, direction: direction, animated: true)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setConstrains()
        setPages()
        setDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoPreview.addLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetPhotoView()
    }
    
    // MARK: - Helpers
    func setPages() {
        pageViewController.setViewControllers([colVC1], direction: .forward, animated: true, completion: nil)
    }
    
    func setDelegates() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        colVC1.delegate = self
        colVC2.delegate = self
    }
    
    private func setConstrains() {
        view.addSubview(photoPreview)
        view.addSubview(segmentedControl)
        view.addSubview(pageViewController.view)
        addChild(pageViewController)
        
        NSLayoutConstraint.activate([
            photoPreview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoPreview.heightAnchor.constraint(equalToConstant: view.frame.height * 0.5),
            
            segmentedControl.topAnchor.constraint(equalTo: photoPreview.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    private func setupNavBar() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "사진 편집"
        
        let completButton = UIButton(type: .system)
        completButton.setImage(UIImage(systemName: "app.badge.checkmark.fill"), for: .normal)
        completButton.tintColor = .black
        completButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: completButton)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 25).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        navigationItem.rightBarButtonItem = menuBarItem
    }
    
    private func updateImage() {
        photoPreview.image = image
    }
    
    private func shareButtonTapped(action: UIAlertAction) {
        if let image = UIImage.imageFromView(view: photoPreview) {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {(activity, success, items, error) in
                if success {
                    self.dismiss(animated: true)
                }
            }
            present(activityViewController, animated: true)
        }
    }
    
    private func resetPhotoView() {
        photoPreview.subviews.forEach { $0.removeFromSuperview() }
        if let _ = photoPreview.layer.sublayers {
            photoPreview.layer.sublayers = []
        }
        photoPreview.addLogo()
    }
    
    private func checkAddPhotoPermission(action: UIAlertAction) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.savePhoto()
                }
            default:
                DispatchQueue.main.async {
                    self.showAuthorizationAlert()
                }
            }
        }
    }
    
    func showAuthorizationAlert() {
        let alert = UIAlertController(title: "앨범 권한", message: "설정에서 사진 권한을 설정 해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "설정하러 가기", style: .default, handler: goToAppSettings))
        
        self.present(alert, animated: true)
    }
    
    
    private func goToAppSettings(_ sender: UIAlertAction) {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    private func savePhoto() {
        if let image = UIImage.imageFromView(view: photoPreview) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
        } else {
            dismiss(animated: true)
        }
        
    }
    
    @objc private func didChangeValue(segment: UISegmentedControl) {
        pageIndex = segment.selectedSegmentIndex
    }
    
    @objc private func completeButtonTapped() {
        let alert = UIAlertController(title: "열심히 만들었으니 공유하자!", message: nil, preferredStyle: .actionSheet)
        
        let share = UIAlertAction(title: "공유하기", style: .default, handler: shareButtonTapped)
        let photo = UIAlertAction(title: "갤러리 저장", style: .default, handler: checkAddPhotoPermission)
        
        [share, photo].forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}

extension PhotoEditVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! UICollectionViewController) else { return nil }
        let previosIndex = index - 1
        if previosIndex < 0 { return nil }
        return pages[previosIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! UICollectionViewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pages.count { return nil }
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageIndex = pageViewController.getCurrentIndex(pages)
        }
    }
}

extension UIPageViewController {
    func getCurrentIndex(_ pages: [UIViewController]) -> Int {
        guard let vc = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc) ?? 0
    }
}

extension PhotoEditVC: DataCollectionDelegate {
    // 어떤 데이터를 넘겨줄것인가?
    // 어떤위치에 추가할것인가?
    func dataCellTapped(_ style: TemplateStyle) {
        guard let runModel = runModel else {
            return
        }
        switch style {
        case .distanceOnly:
            photoPreview.addTextLayerBottom(string: runModel.distance.asString(style: .km).uppercased())
        case .timeOnly:
            photoPreview.addTextLayerBottom(string: runModel.seconds.toMMSSTimeFormat)
        }
    }
    
    func stickerCellTapped(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotaionGestureHandler))
        
        let touchAreaView = UIImageView(frame: imageView.frame)
        touchAreaView.frame.size.width += 20
        touchAreaView.frame.size.height += 20
        imageView.layer.position = touchAreaView.layer.position
        touchAreaView.addSubview(imageView)
        
        touchAreaView.addGestureRecognizer(panGesture)
        touchAreaView.addGestureRecognizer(pinchGesture)
        touchAreaView.addGestureRecognizer(rotationGesture)
        touchAreaView.isUserInteractionEnabled = true
        
        photoPreview.addImageView(touchAreaView)
    }
    

    
    @objc func panGestureHandler(sender: UIPanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        let translation = sender.translation(in: view)
        view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func pinchGestureHandler(sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1.0
    }
    
    @objc func rotaionGestureHandler(sender: UIRotationGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        view.transform = view.transform.rotated(by: sender.rotation)
        sender.rotation = 0.0
    }
}

extension UIImageView {
    /// ImageView위에 텍스트레이어를 추가한다.
    func addTextLayerBottom(string: String) {
        if let _ = layer.sublayers {
            layer.sublayers = layer.sublayers!.filter {
                $0 as? CATextLayer == nil
            }
        }
        
        let textLayer = CATextLayer()
        textLayer.string = string
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.font = UIFont.boldSystemFont(ofSize: 24)
        textLayer.fontSize = 24
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.frame = CGRect(x: 0, y: frame.height - 40, width: frame.width, height: 50)
        layer.addSublayer(textLayer)
    }
    
    func addImageView(_ imageView: UIImageView) {
        imageView.layer.position = .init(x: center.x, y: center.y)
        addSubview(imageView)
    }
    
    func addLogo() {
        let size: CGFloat = 30
        let imageView = UIImageView(frame: .init(x: frame.width - 40, y: 10, width: size, height: size))
        imageView.image = UIImage(resource: .subtract).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
}


