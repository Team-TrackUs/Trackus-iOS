//
//  RecordService.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/28/24.
//

import Foundation
import Firebase

final public class RecordService {
    static let shared = RecordService()
    private init() {}
    
    func uploadRecord(record: Running, completion: @escaping () -> ()) {
        let uid = User.currentUid
        var record = record
        record.timestamp = Date()
        do {
            try Firestore.firestore().collection("user").document(uid).collection("records").addDocument(from: record)
            completion()
        } catch {
            
        }
    }
    
    func fetchRecords() {
        
    }
}
