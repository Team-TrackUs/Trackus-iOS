//
//  DataCollectionVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/6/24.
//

import UIKit



struct ImageDrawBehavior {
    enum Postion {
        case bottom
    }

    enum DataType {
        case onlyDistance
        case onlyTime
    }
    
    let dataType: DataType
    let position: Postion
}

struct ImageDrawType {
    let resource: ImageResource
    let drawBehavior: ImageDrawBehavior
}

class DataCollectionVC: UICollectionViewController {
    let imageTemplates: [ImageDrawType] = [
        ImageDrawType(resource: .photoCell, drawBehavior: .init(dataType: .onlyDistance, position: .bottom)),
        ImageDrawType(resource: .photoCell2, drawBehavior: .init(dataType: .onlyTime, position: .bottom))
    ]
    
    weak var delegate: DataCollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTemplates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DataCollectionCell.reuseIdentifier, for: indexPath) as? DataCollectionCell else {
            return UICollectionViewCell()
        }
        cell.image = UIImage(resource: imageTemplates[indexPath.row].resource)
        return cell
    }
    
    func setupCollectionView() {
        self.collectionView.backgroundColor = .black
        self.collectionView!.register(DataCollectionCell.self, forCellWithReuseIdentifier: DataCollectionCell.reuseIdentifier)
    }
}

extension DataCollectionVC: UICollectionViewDelegateFlowLayout {
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
        delegate?.dataCellTapped(imageTemplates[indexPath.row].drawBehavior)
    }
}
