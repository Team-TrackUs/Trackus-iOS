//
//  Post.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/23/24.
//

import Foundation
import Firebase
import CoreLocation

struct Post: Codable {
    var uid: String
    var title: String
    var content: String
    var courseRoutes: [GeoPoint]
    var distance: Double
    var numberOfPeoples: Int
    var routeImageUrl: String
    var startDate: Date
    var address: String
    var whoReportAt: [String]
    var createdAt: Date
    var runningStyle: Int
    var members: [String]
    var ownerUid: String
    
    init(uid: String, title: String, content: String, courseRoutes: [GeoPoint], distance: Double, numberOfPeoples: Int, routeImageUrl: String, startDate: Date, address: String, whoReportAt: [String], createdAt: Date, runningStyle: Int, members: [String], ownerUid: String) {
        self.uid = uid
        self.title = title
        self.content = content
        self.courseRoutes = courseRoutes
        self.distance = distance
        self.numberOfPeoples = numberOfPeoples
        self.routeImageUrl = routeImageUrl
        self.startDate = startDate
        self.address = address
        self.whoReportAt = whoReportAt
        self.createdAt = createdAt
        self.runningStyle = runningStyle
        self.members = members
        self.ownerUid = ownerUid
    }
    
    mutating func updateRouteImageUrl(newUrl: String) {
        self.routeImageUrl = newUrl
    }
}
