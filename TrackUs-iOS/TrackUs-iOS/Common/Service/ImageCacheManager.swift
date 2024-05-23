//
//  ImageCacheManager.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/22/24.
//

import UIKit


// MARK: - 이미지 캐시 관리
///
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = MemoryCache()
    private let diskCache = DiskCache()
    
    /// 이미지 불러오기 -> UIImage 반환
    func loadImage(imageUrl url: String, completionHandler: @escaping (UIImage?) -> Void) {
        if let image = memoryCache.getImage(forKey: url) {
            // 캐시에 이미지가 있는 경우
            completionHandler(image)
        } else if let image = diskCache.getImage(forKey: url) {
            // 캐시에 없는 경우 디스크 확인
            // 메모리 캐싱
            memoryCache.setImage(image, forKey: url)
            completionHandler(image)
        } else {
            // 메모리, 디스크 둘 다 없는 경우
            downloadImage(imageUrl: url) { image in
                completionHandler(image)
            }
        }
    }
    
    /// (메모리 전용) 이미지 로더
    func memoryloadImage(imageUrl url: String, completionHandler: @escaping (UIImage?) -> Void) {
        if let image = memoryCache.getImage(forKey: url) {
            // 캐시에 이미지가 있는 경우
            completionHandler(image)
        } else {
            // 메모리, 디스크 둘 다 없는 경우
            downloadImage(imageUrl: url) { image in
                completionHandler(image)
            }
        }
    }
    
    // 이미지 저장
    func setImage(_ image: UIImage, forKey key: String) {
        // 메모리 캐싱
        memoryCache.setImage(image, forKey: key)
        // 디스크 캐싱
        diskCache.setImage(image, forKey: key)
    }
    
    /// (메모리 전용) 이미지 저장
    func memorySetImage(_ image: UIImage, forKey key: String) {
        // 메모리 캐싱
        memoryCache.setImage(image, forKey: key)
    }
    
    // 이미지 캐시 등록
    private func downloadImage(imageUrl url: String, completionHandler: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completionHandler(nil)
            return
        }
        // 이미지 다운로드
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let error = error {
                print("이미지 다운로드 실패: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                completionHandler(nil)
                return
            }
            // 캐시 등록
            DispatchQueue.main.async {
                // 이미지 -> 메모리 캐시 등록
                self.memoryCache.setImage(downloadedImage, forKey: url)
                // 이미지 -> 디스크 캐시 등록
                self.diskCache.setImage(downloadedImage, forKey: url)
                completionHandler(downloadedImage)
            }
        }.resume()
    }
    
    /// (메모리 전용) 이미지  캐시 등록
    private func memoryDownloadImage(imageUrl url: String, completionHandler: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completionHandler(nil)
            return
        }
        // 이미지 다운로드
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let error = error {
                print("이미지 다운로드 실패: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                completionHandler(nil)
                return
            }
            // 캐시 등록
            DispatchQueue.main.async {
                // 이미지 -> 메모리 캐시 등록
                self.memoryCache.setImage(downloadedImage, forKey: url)
                completionHandler(downloadedImage)
            }
        }.resume()
    }
}

// MARK: - 메모리 캐싱
class MemoryCache {
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}


// MARK: - 디스크 캐싱
class DiskCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? data.write(to: fileURL)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

extension UIImageView {
    /// 캐시 이미지 불러오기
    func loadImage(url: String) {
        ImageCacheManager.shared.loadImage(imageUrl: url) { image in
            self.image = image
        }
    }
    
    /// (메모리 전용) 캐시 이미지 불러오기
    func memoryloadImage(url: String) {
        ImageCacheManager.shared.memoryloadImage(imageUrl: url) { image in
            self.image = image
        }
    }
}
