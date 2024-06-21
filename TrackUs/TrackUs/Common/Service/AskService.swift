//
//  AskService.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 6/19/24.
//

import Foundation
import Firebase

class AskService {
    
    func askus(userUid: String, text: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("ask")
        
        let data = [
            "uid" : userUid,
            "text" : text
        ] as [String : Any]
        
        ref.document().setData(data) { error in
            completion(error)
        }
    }
}
