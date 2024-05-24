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

class PostService {
    
    var posts = [Post]()
    
    // 포스트 업로드
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
            "members" : post.members
        ] as [String : Any]
        
        Firestore.firestore().collection("posts").document(post.uid).setData(postData) { error in
            completion(error)
        }
    }
    
    // 포스트 참여
    func enterPost() {
        
    }
    
    // 포스트 패치
//    func fetchPost() async throws{
//        let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
//        self.posts = try snapshot.documents.compactMap({ try $0.data(as: Post.self) })
//    }
    
    func fetchPost() async throws {
        let snapshot = try await Firestore.firestore().collection("posts").getDocuments()
        
        for document in snapshot.documents {
            print("읽어오기 시작!")
            print("\(document.documentID) => \(document.data())")
            print("DEBUG: Document data = \(document.data()) ;;")
            print("읽어오기 끝!")
            
            do {
                // Firestore Timestamp를 Swift Date로 변환
                let startDate = (document["startDate"] as? Timestamp)?.dateValue() ?? Date()
                
                // 코스 루트 데이터 가져오기
                guard let courseRoutesData = document["courseRoutes"] as? [GeoPoint] else {
                    print("DEBUG: Failed to get courseRoutesData for document \(document.documentID)")
                    continue
                }
                
                // 필드에 대한 캐스팅 수행
                guard let title = document["title"] as? String,
                      let content = document["content"] as? String,
                      let distance = document["distance"] as? Double,
                      let numberOfPeoples = document["numberOfPeoples"] as? Int,
                      let routeImageUrl = document["routeImageUrl"] as? String,
                      let address = document["address"] as? String,
                      let whoReportAt = document["whoReportAt"] as? [String],
                      let createdAtTimestamp = document["createdAt"] as? Timestamp,
                      let runningStyle = document["runningStyle"] as? Int,
                      let members = document["members"] as? [String] else {
                    print("DEBUG: Failed to cast data for document \(document.documentID)")
                    continue
                }
                
                // Print the fetched data for debugging
                print("DEBUG: Fetched data for document \(document.documentID)")
                print("UID: \(document.documentID)")
                print("Title: \(title)")
                print("Content: \(content)")
                print("Course Routes: \(courseRoutesData)")
                print("Distance: \(distance)")
                print("Number of Peoples: \(numberOfPeoples)")
                print("Route Image URL: \(routeImageUrl)")
                print("Address: \(address)")
                print("Who Report At: \(whoReportAt)")
                print("Created At Timestamp: \(createdAtTimestamp)")
                print("Running Style: \(runningStyle)")
                print("Members: \(members)")
                
                // Post 객체 생성
                let post = Post(
                    uid: document.documentID,
                    title: title,
                    content: content,
                    courseRoutes: courseRoutesData,
                    distance: distance,
                    numberOfPeoples: numberOfPeoples,
                    routeImageUrl: routeImageUrl,
                    startDate: startDate,
                    address: address,
                    whoReportAt: whoReportAt,
                    createdAt: createdAtTimestamp.dateValue(),
                    runningStyle: runningStyle,
                    members: members
                )
                
                // posts 배열에 추가
                self.posts.append(post)
            } catch {
                print("DEBUG: Error processing document \(document.documentID) - \(error.localizedDescription)")
            }
        }
    }
    
    // 포스트 업데이트
    func updatePost() {
        
    }
    
    // 포스트 삭제
    func deletePost() {
        
    }
    
    // 이미지를 스토리지에 업로드
    static func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let resizedImage = image.resizeWithWidth(width: 100) else { return }
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
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
//                ImageCacheManager.shared.setImage(imageData, forkey: url.absoluteString)
                
            }
        }
    }
    
    // 이미지를 스토리지에서 다운로드
    static func downloadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        storageReference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
}
