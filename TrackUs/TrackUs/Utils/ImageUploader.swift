//
//  ImageUploader.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/30/24.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadType {
    case profile
    case post
    case record
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        switch self {
            case .profile:
                return Storage.storage().reference(withPath: "/profileImages/\(User.currentUid)")
            case .post:
                return Storage.storage().reference(withPath: "/posts_image/\(filename)")
            case .record:
                return Storage.storage().reference(withPath: "record_images/\(filename)")
        }
    }
}

enum ErrorType: Error {
    case error
}

struct ImageUploader {
    /// 이미지 업로드
    static func uploadImage(image: UIImage, type: UploadType, compressionQuality: CGFloat = 0.5,  completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { return }
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { meta, error in
            if let error = error {
                print("DEBUG: Failed to upload image : \(error.localizedDescription)")
                return
            }
            
            print("Succesfully upload image...")
            ref.downloadURL { url, _ in
                guard let url = url?.absoluteString else { return }
                completion(url)
            }
        }
    }
    
    /// 이미지업로드 + 캐싱처리
    static func uploadImageWithCaching(image: UIImage, type: UploadType, compressionQuality: CGFloat = 0.5,  completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { return }
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { meta, error in
            if let error = error {
                print("DEBUG: Failed to upload image : \(error.localizedDescription)")
                return
            }
            
            print("Succesfully upload image...")
            ref.downloadURL { url, _ in
                guard let url = url?.absoluteString else { return }
                ImageCacheManager.shared.setImage(image: image, url: url)
                completion(url)
            }
        }
    }
    
    static func uploadImageAsync(image: UIImage, type: UploadType, compressionQuality: CGFloat = 0.5) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { throw ErrorType.error }
            let ref = type.filePath
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            do {
                _ = try await ref.putDataAsync(imageData, metadata: metadata)
               let url = try await ref.downloadURL()
                return url.absoluteString
            } catch {
               throw error
            }
        }
    
    static func uploadImageAsyncChaching(image: UIImage, type: UploadType, compressionQuality: CGFloat = 0.5) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { throw ErrorType.error }
            let ref = type.filePath
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            do {
                _ = try await ref.putDataAsync(imageData, metadata: metadata)
               let url = try await ref.downloadURL()
                let urlString = url.absoluteString
                ImageCacheManager.shared.setImage(image: image, url: urlString)
                return urlString
            } catch {
               throw error
            }
        }
}
