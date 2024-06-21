//
//  Array+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

extension Array where Element == CLLocationCoordinate2D {
    var asGeoPoints: [GeoPoint] {
        self.map {GeoPoint(latitude: $0.latitude, longitude: $0.longitude)}
    }
    
    var centerPosition: CLLocationCoordinate2D? {
        guard !self.isEmpty else {
            return nil
        }
        var totalLatitude: Double = 0
        var totalLongitude: Double = 0
        
        for coordinate in self {
            totalLatitude += coordinate.latitude
            totalLongitude += coordinate.longitude
        }
        let count = Double(self.count)
        let averageLatitude = totalLatitude / count
        let averageLongitude = totalLongitude / count
        
        return CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
    }
    
    var totalDistance: Double {
        var distance: Double = 0
        for i in 0..<self.count - 1 {
            distance += self[i].distance(to: self[i + 1])
        }
        return distance
    }
    
    func makeRegionToFit() -> MKCoordinateRegion? {
        /// 위도, 경도의 4개지점 구하기
        let maxLatitude = self.map {Double($0.latitude)}.max()
        let minLatitude = self.map {Double($0.latitude)}.min()
        let maxLongitude = self.map {Double($0.longitude)}.max()
        let minLongitude = self.map {Double($0.longitude)}.min()
        
        guard let maxLatitude = maxLatitude,
              let minLatitude = minLatitude,
              let maxLongitude = maxLongitude,
              let minLongitude = minLongitude else {
            return nil
        }
        
        let center: CLLocationCoordinate2D
        if let providedCenter = self.centerPosition {
            center = providedCenter
        } else {
            return nil
        }
        
        ///  직선거리 계산에 사용될 더미데이터
        let commLongitude = center.longitude
        let commLatitude = center.latitude
        
        let latitudeDistance = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: minLatitude), longitude: commLongitude).distance(to: CLLocationCoordinate2D(latitude: maxLatitude, longitude: commLongitude))
        
        let longitudeDistance = CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: commLatitude), longitude: minLongitude).distance(to: CLLocationCoordinate2D(latitude: commLatitude, longitude: maxLongitude))
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: latitudeDistance, longitudinalMeters: longitudeDistance)
        
        return region
    }
    
    func convertCoordinatesToImagePoints(coordinates: [CLLocationCoordinate2D], rect: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        
        let minLat = coordinates.min { $0.latitude < $1.latitude }!.latitude
        let maxLat = coordinates.max { $0.latitude < $1.latitude }!.latitude
        let minLon = coordinates.min { $0.longitude < $1.longitude }!.longitude
        let maxLon = coordinates.max { $0.longitude < $1.longitude }!.longitude
        
        let latRange = maxLat - minLat // 최대위도, 최소위도
        let lonRange = maxLon - minLon // 최대경도, 최소경도
        
        for coordinate in coordinates {
            let x = (coordinate.longitude - minLon) / lonRange * Double(rect.width)
            let y = (1 - (coordinate.latitude - minLat) / latRange) * Double(rect.height)
            
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}

extension Array where Element == GeoPoint {
    var asCLCoordinate2D: [CLLocationCoordinate2D] {
        self.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}


