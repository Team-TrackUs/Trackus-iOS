//
//  RunTrackingManager.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/17/24.
//

import Foundation
import CoreLocation
import CoreMotion

/**
 러닝트래킹 매니저
 */
final public class RunTrackingManager {
    private let pedometer = CMPedometer()
    private let altimeter = CMAltimeter()
    private var runningModel = Running()

    var coordinates: [CLLocationCoordinate2D] {
        get { runningModel.coordinates }
        set { runningModel.coordinates = newValue }
    }
    
    var seconds: Double {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    /// 운동정보감지 업데이트 핸들러
    func startRecord(completion: @escaping (Running) -> Void) {
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let self = self else { return }
            guard let pedometerData = pedometerData, error == nil else { return }
            runningModel.distance = pedometerData.distance?.doubleValue ?? 0.0
            runningModel.pace = (runningModel.seconds / 60) / (runningModel.distance / 1000.0)
            runningModel.cadance = Int(pedometerData.numberOfSteps.doubleValue / (runningModel.seconds / 60))
            
            completion(runningModel)
        }
        
        altimeter.startAbsoluteAltitudeUpdates(to: .main) { altimeterData, error in
            guard let altimeterData = altimeterData, error == nil else { return }
            print(altimeterData.altitude)
        }
    }
    
    /// 핸들러 중지
    func stopRecord() {
        pedometer.stopUpdates()
        altimeter.stopAbsoluteAltitudeUpdates()
    }
}
