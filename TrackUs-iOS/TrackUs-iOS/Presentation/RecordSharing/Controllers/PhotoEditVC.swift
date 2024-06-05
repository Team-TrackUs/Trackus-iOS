//
//  PhotoEditVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/5/24.
//

import UIKit

final class PhotoEditVC: UIViewController {
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private lazy var photoPreview: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = image
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
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
    
    // MARK: - Helpers
    
    func setPages() {
        pageViewController.setViewControllers([colVC1], direction: .forward, animated: true, completion: nil)
    }
    
    func setDelegates() {
        pageViewController.delegate = self
        pageViewController.dataSource = self        
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
            photoPreview.heightAnchor.constraint(equalToConstant: view.frame.height * 0.4),
            
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
        dismiss(animated: true)
    }
    
    private func photoButtonTapped(action: UIAlertAction) {
        dismiss(animated: true)
    }
    
    @objc private func didChangeValue(segment: UISegmentedControl) {
        pageIndex = segment.selectedSegmentIndex
    }
   
    @objc private func completeButtonTapped() {
        let alert = UIAlertController(title: "열심히 만들었으니 공유하자!", message: nil, preferredStyle: .actionSheet)
        
        let share = UIAlertAction(title: "공유하기", style: .default, handler: shareButtonTapped)
        let photo = UIAlertAction(title: "갤러리 저장", style: .default, handler: photoButtonTapped)
        
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


