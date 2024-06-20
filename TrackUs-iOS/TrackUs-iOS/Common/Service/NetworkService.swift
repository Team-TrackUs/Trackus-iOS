//
//  NetworkService.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 6/14/24.
//

import UIKit
import Network

struct NetworkService {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    
    func startCheckingNetwork() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["isConnected": isConnected])
        }
    }
    
    func stopCheckingNetwork() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

class NetworkErrorView: UIView {
    private let textlabel: UILabel = {
        let label = UILabel()
        label.text = "네트워크 연결에 실패하였습니다."
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        addSubview(textlabel)
        textlabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textlabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textlabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textlabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
