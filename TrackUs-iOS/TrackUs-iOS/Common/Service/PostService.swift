//
//  PostService.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/23/24.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore
import CoreLocation

class PostService {
    
    var posts = [Post]()
    
    // 모집글 업로드
    func uploadPost(post: Post, completion: @escaping (Error?) -> Void) {
        
        let postData = [
            "uid" : post.uid,
            "title" : post.title,
            "content" : post.content,
            "courseRoutes" : post.courseRoutes,
            "distance" : post.distance,
            "numberOfPeoples" : post.numberOfPeoples,
            "routeImageUrl" : post.routeImageUrl,
            "startDate" : post.startDate,
            "address" : post.address,
            "whoReportAt" : post.whoReportAt,
            "createdAt" : post.createdAt,
            "runningStyle" : post.runningStyle,
            "members" : post.members,
            "ownerUid" : post.ownerUid
        ] as [String : Any]
        
        Firestore.firestore().collection("posts").document(post.uid).setData(postData) { error in
            completion(error)
        }
    }
    
    // 모집글 참여
    func enterPost(postUid: String, userUid: String, members: [String], completion: @escaping ([String]?, Error?) -> Void) {
        Firestore.firestore().collection("posts").document(postUid).getDocument { snapshot, error in
            guard let document = try? snapshot?.data(as: Post.self), error == nil else {
                completion(nil, error)
                return
            }
            
            if document.members.count >= document.numberOfPeoples {
                let capacityError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Post is already full"])
                completion(nil, capacityError)
                return
            }
            
            var updatedMembers = document.members
            updatedMembers.append(userUid)
            
            Firestore.firestore().collection("posts").document(postUid).updateData(["members": updatedMembers]) { updateError in
                if let updateError = updateError {
                    completion(nil, updateError)
                } else {
                    completion(updatedMembers, nil)
                }
            }
        }
    }
    
    // 모집글 나가기
    func exitPost(postUid: String, userUid: String, members: [String], completion: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("posts").document(postUid).getDocument { snapshot, error in
            guard let document = try? snapshot?.data(as: Post.self) else { return }
            let updatedMembers = document.members.filter { $0 != userUid }
            Firestore.firestore().collection("posts").document(postUid).updateData(["members": updatedMembers]) { _ in
                completion(updatedMembers)
            }
        }
    }
    
    // 모집글 테이블 패치
    func fetchPostTable(startAfter: DocumentSnapshot?, limit: Int, completion: @escaping ([Post]?, DocumentSnapshot?, Error?) -> Void) {
        var query = Firestore.firestore().collection("posts").order(by: "createdAt", descending: true).limit(to: limit)
        
        let userUid = User.currentUid
        let userManager = UserManager.shared
        userManager.getUserData(uid: userUid)
        let user = userManager.user
        let blockList = user.blockList
        
        var filteredPosts = [Post]()
        
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([], nil, nil)
                return
            }
            
            let _ = documents.compactMap { queryDocumentSnapshot -> Post? in
                guard let post = try? queryDocumentSnapshot.data(as: Post.self) else {
                    return nil
                }
                
                let postMembers = post.members
                let whoReportAt = post.whoReportAt
                
                if !blockList.contains(post.ownerUid) && (whoReportAt.count) <= 2 {
                    filteredPosts.append(post)
                }
                
                return post
            }
            
            let lastDocumentSnapshot = documents.last
            completion(filteredPosts, lastDocumentSnapshot, nil)
        }
    }
    
    // 맵뷰의 중앙과 코스 시작점과의 거리 계산
    func distanceBetweenCourse(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
        let region = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
        let course = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
        return region.distance(from: course)
    }
    
    // 러닝맵 모집글 불러오기
    func fetchMap(regionCenter: CLLocationCoordinate2D, completion: @escaping ([Post]?, DocumentSnapshot?, Error?) -> Void) {
        var query = Firestore.firestore().collection("posts").order(by: "createdAt", descending: true)
        
        let userUid = User.currentUid
        let userManager = UserManager.shared
        userManager.getUserData(uid: userUid)
        let user = userManager.user
        let blockList = user.blockList
        
        var filteredPosts = [Post]()
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([], nil, nil)
                return
            }
            
            let _ = documents.compactMap { queryDocumentSnapshot -> Post? in
                guard let post = try? queryDocumentSnapshot.data(as: Post.self) else {
                    return nil
                }
                
                guard let courseRoute = post.courseRoutes.first else {
                    return nil
                }
                
                let courseRouteStart = CLLocationCoordinate2D(latitude: courseRoute.latitude, longitude: courseRoute.longitude)
                let distance = self.distanceBetweenCourse(regionCenter, courseRouteStart)
                
                
                let postMembers = post.members
                let whoReportAt = post.whoReportAt
                
                if !blockList.contains(post.ownerUid) && distance <= 5000 && (whoReportAt.count) <= 2 {
                    filteredPosts.append(post)
                }
                
                return post
            }
            
            let lastDocumentSnapshot = documents.last
            completion(filteredPosts, lastDocumentSnapshot, nil)
        }
    }
    
    // 해당 모집글 정보 불러오기
    func fetchPost(uid: String, completion: @escaping (Post?, Error?) -> Void) {
        Firestore.firestore().collection("posts").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch post = \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let document = snapshot?.data() else {
                completion(nil, nil)
                return
            }
            
            guard let title = document["title"] as? String,
                  let content = document["content"] as? String,
                  let courseRoutes = document["courseRoutes"] as? [GeoPoint],
                  let distance = document["distance"] as? Double,
                  let numberOfPeoples = document["numberOfPeoples"] as? Int,
                  let routeImageUrl = document["routeImageUrl"] as? String,
                  let startDate = (document["startDate"] as? Timestamp)?.dateValue(),
                  let address = document["address"] as? String,
                  let whoReportAt = document["whoReportAt"] as? [String],
                  let createdAt = (document["createdAt"] as? Timestamp)?.dateValue(),
                  let runningStyle = document["runningStyle"] as? Int,
                  let members = document["members"] as? [String],
                  let ownerUid = document["ownerUid"] as? String else {
                print("DEBUG: Failed to cast data for document \(uid)")
                completion(nil, nil)
                return
            }
            
            let post = Post(
                uid: uid,
                title: title,
                content: content,
                courseRoutes: courseRoutes,
                distance: distance,
                numberOfPeoples: numberOfPeoples,
                routeImageUrl: routeImageUrl,
                startDate: startDate,
                address: address,
                whoReportAt: whoReportAt,
                createdAt: createdAt,
                runningStyle: runningStyle,
                members: members,
                ownerUid: ownerUid
            )
            
            completion(post, nil)
        }
    }
    
    // 모집글 수정
    func editPost(post: Post, completion: @escaping (Error?) -> Void) {
        let postData = [
            "title" : post.title,
            "content" : post.content,
            "courseRoutes" : post.courseRoutes,
            "distance" : post.distance,
            "numberOfPeoples" : post.numberOfPeoples,
            "routeImageUrl" : post.routeImageUrl,
            "startDate" : post.startDate,
            "address" : post.address,
            "whoReportAt" : post.whoReportAt,
            "createdAt" : post.createdAt,
            "runningStyle" : post.runningStyle,
            "members" : post.members,
            "ownerUid" : post.ownerUid
        ] as [String : Any]
        
        Firestore.firestore().collection("posts").document(post.uid).updateData(postData) { error in
            completion(error)
        }
    }
    
    // 모집글 삭제
    func deletePost(postUid: String, imageUrl: String, completion: @escaping () -> ()) {
        Firestore.firestore().collection("posts").document(postUid).delete { error in
            completion()
        }
        
        deleteImage(imageUrl: imageUrl)
    }
    
    // 이미지를 스토리지에 업로드
    static func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let resizedImage = image.resizeWithWidth(width: 100) else { return }
        guard let imageData = resizedImage.jpegData(compressionQuality: 1.0) else {
            print("DEBUG: Failed to convert image to data")
            completion(nil)
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        
        let firebaseReference = Storage.storage().reference().child("posts_image").child(imageName)
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error {
                print("DEBUG: Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            firebaseReference.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url)
                
                // 이미지 setImage
                // ImageCacheManager.shared.setImage(imageData, forkey: url.absoluteString)
                
            }
        }
    }
    
    // 이미지를 스토리지에서 삭제
    func deleteImage(imageUrl: String) {
        let storageReference = Storage.storage().reference(forURL: imageUrl)
        storageReference.delete { error in
            print("DEBUG: Image Delete Failed = \(String(describing: error?.localizedDescription))")
        }
    }
    
    // 모집글 참여인원의 프로필이미지와 이름 가져오기
    func fetchMembers(uid: String, completion: @escaping (String?, String?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            
            if let error = error {
                completion(nil, nil)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            let name = data["name"] as? String ?? ""
            let imageUrl = data["profileImageUrl"] as? String ?? ""
            
            completion(name, imageUrl)
            return
        }
    }
    
    // 검색어 필터링
    func searchFilter(searchText: String, completion: @escaping ([Post]) -> Void) {
        let searchToken = searchText.lowercased()
        
        Firestore.firestore().collection("posts")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Search Error \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("DEBUG: No documents found for searchText: \(searchText)")
                    completion([])
                    return
                }
                
                var filterPosts = [Post]()
                documents.forEach { document in
                    let data = document.data()
                    
                    guard let title = data["title"] as? String,
                          let content = data["content"] as? String,
                          let courseRoutes = data["courseRoutes"] as? [GeoPoint],
                          let distance = data["distance"] as? Double,
                          let numberOfPeoples = data["numberOfPeoples"] as? Int,
                          let routeImageUrl = data["routeImageUrl"] as? String,
                          let startDateTimestamp = data["startDate"] as? Timestamp,
                          let address = data["address"] as? String,
                          let whoReportAt = data["whoReportAt"] as? [String],
                          let createdAtTimestamp = data["createdAt"] as? Timestamp,
                          let runningStyle = data["runningStyle"] as? Int,
                          let members = data["members"] as? [String],
                          let ownerUid = data["ownerUid"] as? String else {
                        print("DEBUG: Invalid document data for documentID: \(document.documentID)")
                        return
                    }
                    
                    // 검색어가 제목에 포함되어 있는지 확인
                    if title.lowercased().contains(searchToken) {
                        let post = Post(uid: document.documentID,
                                        title: title,
                                        content: content,
                                        courseRoutes: courseRoutes,
                                        distance: distance,
                                        numberOfPeoples: numberOfPeoples,
                                        routeImageUrl: routeImageUrl,
                                        startDate: startDateTimestamp.dateValue(),
                                        address: address,
                                        whoReportAt: whoReportAt,
                                        createdAt: createdAtTimestamp.dateValue(),
                                        runningStyle: runningStyle,
                                        members: members,
                                        ownerUid: ownerUid)
                        
                        filterPosts.append(post)
                    }
                }
                completion(filterPosts)
            }
    }
    
    // 모집글 신고
    func reportPost(postUid: String, userUid: String, category: String, text: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(postUid)
        
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var postData = document.data()!
                var whoReportAt = postData["whoReportAt"] as? [String] ?? []
                
                if whoReportAt.contains(userUid) {
                    print("DEBUG: Error = User has already reported this post")
                    completion(false)
                    return
                }
                
                whoReportAt.append(userUid)
                postData["whoReportAt"] = whoReportAt
                
                postRef.updateData(["whoReportAt": whoReportAt]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        completion(false)
                        return
                    }
                    
                    let report = [
                        "toUser": postData["ownerUid"] as! String,
                        "fromUser": userUid,
                        "category": category,
                        "text": text,
                        "createdAt": Date()
                    ] as [String : Any]
                    
                    postRef.collection("reasons").addDocument(data: report) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                            completion(false)
                        } else {
                            print("Document added successfully")
                            completion(true)
                        }
                    }
                }
            } else {
                print("Error: Post not found")
                completion(false)
            }
        }
    }
    
    // 사용자 내보내기
    func kickUser(postUid: String, userUid: String, completion: @escaping ([String]?, Error?) -> Void) {
        Firestore.firestore().collection("posts").document(postUid).getDocument { snapshot, error in
            guard let document = try? snapshot?.data(as: Post.self), error == nil else {
                completion(nil, error)
                return
            }
            
            var updateMembers = document.members
            
            if let index = updateMembers.firstIndex(of: userUid) {
                updateMembers.remove(at: index)
            } else {
                return
            }
            
            Firestore.firestore().collection("posts").document(postUid).updateData(["members": updateMembers]) { updateError in
                if let updateError = updateError {
                    completion(nil, updateError)
                } else {
                    completion(updateMembers, nil)
                }
            }
        }
    }
}
