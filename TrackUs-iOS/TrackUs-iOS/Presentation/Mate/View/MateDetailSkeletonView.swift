//
//  MateDetailSkeletonView.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 6/2/24.
//

import UIKit

class MateDetailSkeletonView: UIView {
    
    // MARK: - Properties
    
    let mapView = UIView()
    let dateView = UIView()
    let titleView = UIView()
    let locationView = UIView()
    let descriptionView = UIView()
    
    private var isAnimating = true
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        configureUI()
        startAnimatingViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        stopAnimatingViews()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        backgroundColor = .white
        addSubview(mapView)
        addSubview(dateView)
        addSubview(titleView)
        addSubview(locationView)
        addSubview(descriptionView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        mapView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 310).isActive = true
        mapView.backgroundColor = .gray2
        mapView.layer.cornerRadius = 12
        
        dateView.translatesAutoresizingMaskIntoConstraints = false
        dateView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        dateView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16).isActive = true
        dateView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        dateView.backgroundColor = .gray2
        dateView.layer.cornerRadius = 5
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        titleView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 16).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        titleView.backgroundColor = .gray2
        titleView.layer.cornerRadius = 5
        
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        locationView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16).isActive = true
        locationView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        locationView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        locationView.backgroundColor = .gray2
        locationView.layer.cornerRadius = 5
        
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        descriptionView.topAnchor.constraint(equalTo: locationView.bottomAnchor, constant: 16).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        descriptionView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        descriptionView.backgroundColor = .gray2
        descriptionView.layer.cornerRadius = 5
    }
    
    private func startAnimatingViews() {
        animateView(view: mapView)
        animateView(view: dateView)
        animateView(view: titleView)
        animateView(view: locationView)
        animateView(view: descriptionView)
    }
    
    private func stopAnimatingViews() {
        isAnimating = false
    }
    
    private func animateView(view: UIView) {
        guard isAnimating else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            view.alpha = 0.1
        }, completion: { _ in
            if self.isAnimating {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                    view.alpha = 1.0
                })
            }
        })
    }
}

