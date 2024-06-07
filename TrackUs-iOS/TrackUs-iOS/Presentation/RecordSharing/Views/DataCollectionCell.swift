//
//  DataCollectionCell.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/6/24.
//

import UIKit

protocol DataCollectionDelegate: AnyObject {
    func dataCellTapped(_ :ImageDrawBehavior)
}

class DataCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "DataCell"
   
    var image: UIImage? {
        didSet {
            setImage()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = image
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage() {
        imageView.image = image
    }
    
    func setupConstraints() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
}
