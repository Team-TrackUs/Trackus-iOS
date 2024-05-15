//
//  RunActivityVC.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/13/24.
//
// TODO: - 스와이프 구현
// tanslation x값을 측정
// 버튼의 center.x값을 이동한 값만큼 추가
//  <= center.x

import UIKit
import MapKit

final class RunActivityVC: UIViewController {
    private var mapView: MKMapView!
    private let locationService = LocationService.shared
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "3"
        label.font = UIFont.boldSystemFont(ofSize: 58)
        label.textColor = .white
        return label
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 20
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "잠시 후 러닝이 시작됩니다!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        [countLabel, label].forEach {st.addArrangedSubview($0)}
        view.addSubview(st)
        st.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        st.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }()
    
    private lazy var swipeBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.layer.cornerRadius = 35
        let label = UILabel()
        label.text = "밀어서 러닝 종료"
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(actionButton)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.isHidden = true
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.layer.cornerRadius = 25
        btn.backgroundColor = .white
        let image = UIImage(systemName: "pause.fill")
        
        btn.setImage(image, for: .normal)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pangestureHandler))
        btn.addGestureRecognizer(panGesture)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setMapRegion()
        setConstraint()
        setTimer()
    }
    
    func setConstraint() {
        self.view.addSubview(overlayView)
        self.view.addSubview(swipeBox)
        
        NSLayoutConstraint.activate([
            swipeBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            swipeBox.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            swipeBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            swipeBox.heightAnchor.constraint(equalToConstant: 70),
            
            actionButton.leadingAnchor.constraint(equalTo: swipeBox.leadingAnchor, constant: 10),
            actionButton.topAnchor.constraint(equalTo: swipeBox.topAnchor, constant: 10),
            actionButton.bottomAnchor.constraint(equalTo: swipeBox.bottomAnchor, constant: -10),
        ])
    }
    
    func setupMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func setMapRegion() {
        let defaultSpanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        if let currentLocation = locationService.currentLocation {
            mapView.setRegion(.init(center: currentLocation, span: defaultSpanValue), animated: true)
        }
    }
    
    func updateOnStart() {
        self.overlayView.isHidden = true
        self.swipeBox.isHidden = false
    }
    
    func setTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let number = self.countLabel.text!.asNumber
            if number == 1 {
                self.updateOnStart()
                return
            }
            self.countLabel.text = (number - 1).asString
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            self.countLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
    }
    
    @objc func pangestureHandler(sender: UIPanGestureRecognizer) {
        let minX = actionButton.bounds.width / 2 + 10
        let translation = sender.translation(in: actionButton)
        
        let newX = actionButton.center.x + translation.x
        let maxX = swipeBox.bounds.maxX - CGFloat(35)
        actionButton.center.x = max(minX, min(newX, maxX))
        sender.setTranslation(CGPoint.zero, in: actionButton)
        
        if sender.state == .ended && newX > maxX * 0.9 {
            goToResultVC()
        } else if sender.state == .ended  {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.actionButton.center.x = minX
            }
        }
    }
    
    func goToResultVC() {
        let resultVC = RunningResultVC()
        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}

extension String {
    var asNumber: Int {
        guard let number = Int(self) else { return 0 }
        return number
    }
}
