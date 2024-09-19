//
//  CoreMotion.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/26/24.
//

import Foundation
import CoreMotion

class CoreMotionService {
    enum AuthrizationStatus {
        case authorized
        case denied
    }
    
    static let shared = CoreMotionService()
    let pedometer = CMPedometer()
    let altimeter = CMAltimeter()
    private init() {}
    
    /// 동작감지 허용여부 확인
    func checkAuthrization(completion: @escaping (AuthrizationStatus) -> Void) {
        if CMPedometer.authorizationStatus() == .authorized {
            completion(.authorized)
        } else if CMPedometer.authorizationStatus() == .notDetermined {
            pedometer.startEventUpdates { (_, _) in}
        } else {
            completion(.denied)
        }
    }
}
