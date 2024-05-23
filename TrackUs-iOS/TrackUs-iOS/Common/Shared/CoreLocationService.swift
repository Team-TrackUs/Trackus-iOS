//
//  CoreLocationService.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/23/24.
//

import Foundation
import CoreMotion

class CoreLocationService {
    enum AuthrizationStatus {
        case authorized
        case denied
    }
    private init() {}
    
    static let pedometer = CMPedometer()
    
    static func checkAuthrization(completion: @escaping (AuthrizationStatus) -> Void) {
        if CMPedometer.authorizationStatus() == .authorized {
            completion(.authorized)
        } else if CMPedometer.authorizationStatus() == .notDetermined {
            pedometer.startEventUpdates { (_, _) in}
        } else {
            completion(.denied)
        }
    }
}
