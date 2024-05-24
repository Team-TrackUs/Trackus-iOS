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
    
    // 포스트 업로드
    func uploadPost(post: Post, completion: @escaping (Error?) -> Void) {
        
        let postData = [
            "uid" : post.uid,
            "title" : post.title,
            "content" : post.content,
            "courseRoutes" : post.courseRoutes,
            "distance" : post.distance,
            "isEdit" : post.isEdit,
            "numberOfPeoples" : post.numberOfPeoples,
            "routeImageUrl" : post.routeImageUrl,
            "startDate" : post.startDate,
            "address" : post.address,
            "whoReportAt" : post.whoReportMe,
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
    func fetchPost() {
        
    }
    
    // 포스트 업데이트
    func updatePost() {
        
    }
    
    // 포스트 삭제
    func deletePost() {
        
    }
    
    // 이미지를 스토리지에 업로드
    static func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
//        guard let resizedImage = image.resize(width: 300, height: 300) else { return }
//        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
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
