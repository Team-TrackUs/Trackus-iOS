//
//  RunTrackingManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import CoreLocation

final class RunTrackingManager {
    private var runningModel = Running()
    
    var seconds: Int {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    /// 좌표경로 추가
    func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        
    }
}
