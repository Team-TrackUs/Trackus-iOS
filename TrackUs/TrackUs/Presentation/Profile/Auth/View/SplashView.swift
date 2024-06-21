//
//  SplashView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/20/24.
//

import UIKit

class SplashView: UIViewController {
    
    private lazy var image: UIImageView = {
        let image = UIImage(named: "splash_icon")?.resize(width: 90, height: 73)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.userInterfaceStyle == .dark {
            // 다크 모드일 때의 색상
            view.backgroundColor = .black
        } else {
            // 라이트 모드일 때의 색상
            view.backgroundColor = .mainBlue
        }
        //view.backgroundColor = .white
        setupAutoLayout()
    }
    
    private func setupAutoLayout() {
        
        self.view.addSubview(image)
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -80),
            image.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        ])
    }
}
