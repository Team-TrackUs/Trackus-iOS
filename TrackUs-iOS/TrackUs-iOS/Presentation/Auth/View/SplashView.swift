//
//  SplashView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/20/24.
//

import UIKit

class SplashView: UIViewController {
    
    private lazy var image: UIImageView = {
        let image = UIImage(named: "trackus_icon")?.resize(width: 90, height: 73)
        image?.withTintColor(.white, renderingMode: .alwaysTemplate)
        //image?.size.width = 30
        return UIImageView(image: image)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .mainBlue
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
