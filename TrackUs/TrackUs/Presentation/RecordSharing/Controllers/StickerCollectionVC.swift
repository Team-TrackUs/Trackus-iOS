//
//  DataCollectionVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/6/24.
//

import UIKit



class StickerCollectionVC: UICollectionViewController {
    private let resources: [ImageResource] = [
        .test1,
        .test2,
        .test3,
        .test4,
        .test5,
        .test6,
        .test7,
        .test8
    ]
    weak var delegate: DataCollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    func setupCollectionView() {
        self.collectionView.backgroundColor = .black
        self.collectionView!.register(StickerCollectionCell.self, forCellWithReuseIdentifier: StickerCollectionCell.reuseIdentifier)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionCell.reuseIdentifier, for: indexPath) as? StickerCollectionCell else {
            return UICollectionViewCell()
        }
        cell.image = UIImage(resource: resources[indexPath.row])
        return cell
    }
}

extension StickerCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width/3) - 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.stickerCellTapped(UIImage(resource: resources[indexPath.row]))
    }
}
