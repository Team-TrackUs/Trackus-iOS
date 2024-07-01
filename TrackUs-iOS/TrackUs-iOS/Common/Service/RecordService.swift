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
    
    func uploadRecord(record: Running, image: UIImage) async {
        let uid = User.currentUid
        var record = record
        
        do {
            let url = try await ImageUploader.uploadImageAsyncChaching(image: image, type: .record)
            record.setUrl(url)
            record.setTime()
            try Firestore.firestore().collection("users").document(uid).collection("records").addDocument(from: record)
            
        } catch {
            print(#function + "upload failed")
        }
    }
    
    func fetchRecords() {
        
    }
}
