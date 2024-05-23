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

    /// 러닝시간
    var seconds: Double {
        get { runningModel.seconds }
        set { runningModel.seconds = newValue }
    }
    
    /// 좌표
    var coordinates: [CLLocationCoordinate2D] {
        get { runningModel.coordinates }
        set { runningModel.coordinates = newValue }
    }
    
    /// 이동거리
    var distance: Double {
        get { runningModel.distance }
        set { runningModel.distance = newValue }
    }
    
    /// 평균페이스
    var pace: Double  {
        get { runningModel.pace }
        set { runningModel.pace = newValue }
    }
    
    var cadance: Int {
        get { runningModel.cadance }
        set { runningModel.cadance = newValue }
    }
    
    /// 운동정보감지 업데이트 핸들러
    func startRecord(completion: @escaping () -> Void) {
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let self = self else { return }
            guard let pedometerData = pedometerData, error == nil else { return }
            distance = pedometerData.distance?.doubleValue ?? 0.0
            pace = (seconds / 60) / (distance / 1000.0)
            cadance = Int(pedometerData.numberOfSteps.doubleValue / (seconds / 60))
            
            DispatchQueue.main.async {
                completion()
            }
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
