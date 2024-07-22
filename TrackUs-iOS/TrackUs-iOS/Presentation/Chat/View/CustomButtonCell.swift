//
//  CustomButtonCell.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/8/24.
//

import UIKit

/// 하단 버튼용 커스텀 버튼 셀
class CustomButtonCell: UICollectionViewCell {
    private let customButtonView: CustomButtonView = {
        let view = CustomButtonView(imageName: "", labelText: "", backgroundColor: .clear)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(customButtonView)
        customButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customButtonView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            customButtonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customButtonView.widthAnchor.constraint(equalToConstant: 50),
            customButtonView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageName: String, labelText: String, backgroundColor: UIColor) {
        customButtonView.removeFromSuperview()
        let newView = CustomButtonView(imageName: imageName, labelText: labelText, backgroundColor: backgroundColor)
        contentView.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            newView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newView.widthAnchor.constraint(equalToConstant: 50),
            newView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}


// 전송 버튼
class CustomButtonView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    init(imageName: String, labelText: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        
        imageView.image = UIImage(systemName: imageName)
        imageView.frame.size = CGSize(width: 30, height: 30)
        
        let container = UIView()
        container.frame.size = CGSize(width: 50, height: 50)
        container.backgroundColor = backgroundColor
        container.layer.cornerRadius = 25
        container.addSubview(imageView)
        imageView.center = container.center
        
        addSubview(container)
        addSubview(label)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.widthAnchor.constraint(equalToConstant: 50),
            container.heightAnchor.constraint(equalToConstant: 50),
            
            label.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        label.text = labelText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
