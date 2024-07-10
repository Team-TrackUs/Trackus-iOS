//
//  ImageDetailVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/10/24.
//

import UIKit

class ImageDetailVC: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage?
    var imageName: String?
    var imageDate: String?
    
    private lazy var scrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        //scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }()
    
    private lazy var shareButton = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "square.and.arrow.up")
        button.tintColor = .gray1
        button.target = self
        button.action = #selector(shareButtonTapped)
        return button
    }()
    
    private lazy var downloadButton = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "arrow.down.to.line.compact")
        button.tintColor = .gray1
        button.target = self
        button.action = #selector(downloadButtonTapped)
        return button
    }()
    
    private lazy var nameLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.text = imageName
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dateLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray2
        label.text = imageDate
        label.textAlignment = .center
        return label
    }()
    
    
    private let toolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupToolbar()
        setupScrollView()
        setupImageView()
    }

    // MARK: - 오토 레이아웃 세팅
    
    // 네비게이션바 세팅
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(dismissDetailViewController))
        backButton.tintColor = .gray1
        
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)
        titleView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor, constant: -5),
            nameLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            
            dateLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor, constant: 12)
        ])
        
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = backButton
    }
    
    // 툴바 버튼 세팅
    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // 툴바 표시
        navigationController?.isToolbarHidden = false
        self.toolbarItems = [shareButton, flexibleSpace, downloadButton]
    }
    
    // 스크롤뷰 세팅
    private func setupScrollView() {

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // 이미지뷰 세팅
    private func setupImageView() {
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // MARK: - Actions
    @objc private func dismissDetailViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func shareButtonTapped() {
        guard let image = image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }

    @objc private func downloadButtonTapped() {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "저장 실패", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "저장 성공", message: "이미지가 사진 앨범에 저장되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
