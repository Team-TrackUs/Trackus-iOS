//
//  ImagePickerVC.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/1/24.
//

import UIKit
import Photos

protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ picker: ImagePickerVC, didSelectImage image: UIImage)
}

class ImagePickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: ImagePickerDelegate?
    private var collectionView: UICollectionView!
    private var fetchResult: PHFetchResult<PHAsset>?
    private var selectedImage: UIImage? {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = selectedImage == nil ? false : true
        }
    }
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupCollectionView()
        fetchPhotos()
    }

    private func setupNavigationBar() {
        navigationItem.title = "최근 항목"
        
        let doneButton = UIBarButtonItem(title: "전송", style: .done, target: self, action: #selector(doneButtonTapped))
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(imagePickerControllerDidCancel))
        
        backButton.tintColor = .gray1
        
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 3 - 1, height: view.frame.width / 3 - 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white

        view.addSubview(collectionView)
    }

    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        collectionView.reloadData()
    }

    @objc private func doneButtonTapped() {
        // 선택 이미지 전달
        if let selectedImage = selectedImage {
            delegate?.imagePicker(self, didSelectImage: selectedImage)
        }
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchResult?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        // 첫번째 사진 촬영 셀
        if indexPath.item == 0 {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .gray1
            imageView.image = UIImage(systemName: "camera.fill")
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel(frame: cell.contentView.bounds)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "사진 찍기"
            label.textAlignment = .center
            label.textColor = .gray1
            label.font = .systemFont(ofSize: 16)
            
            cell.contentView.addSubview(imageView)
            cell.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 15),
                imageView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: -15)
                ])
        } else {
            // 앨범 사진 목록 셀
            let asset = fetchResult?.object(at: indexPath.item - 1)
            let imageView = UIImageView(frame: cell.contentView.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            // 이미지 불러오기 옵션 지정
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.deliveryMode = .highQualityFormat
            
            // 이미지 불러오기
            PHImageManager.default().requestImage(for: asset!, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill, options: options) { image, _ in
                imageView.image = image
            }

            cell.contentView.addSubview(imageView)

            if indexPath == selectedIndexPath {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.mainBlue.cgColor
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
                cell.contentView.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: cell.topAnchor),
                    view.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                    view.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                    ])
            } else {
                cell.layer.borderWidth = 0
                cell.contentView.backgroundColor = .clear
            }
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    /// 선택 이미지 전달 델리게이트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 첫번째셀 사진 촬영
        if indexPath.item == 0 {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            let asset = fetchResult?.object(at: indexPath.item - 1)
            PHImageManager.default().requestImageDataAndOrientation(for: asset!, options: nil) { data, _, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    if self.selectedIndexPath != indexPath {
                        self.selectedImage = image
                        // 선택된 항목만 다시 로드
                        DispatchQueue.main.async {
                            if let selectedIndexPath = self.selectedIndexPath {
                                self.selectedIndexPath = indexPath
                                // 이전 선택 이미지 다시 로드
                                self.collectionView.reloadItems(at: [selectedIndexPath])
                                // 선택 이미지 다시 로드
                                self.collectionView.reloadItems(at: [indexPath])
                            } else {
                                self.selectedIndexPath = indexPath
                                // 선택 이미지 다시 로드
                                self.collectionView.reloadItems(at: [indexPath])
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            delegate?.imagePicker(self, didSelectImage: image)
        }
        picker.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.popViewController(animated: true)
    }
}
