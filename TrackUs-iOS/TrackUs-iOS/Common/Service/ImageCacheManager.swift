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
        guard let imageUrl = URL(string: url) else { return }
        // 디스크 저장 가능한 형태로 키값 변경
        let keyUrl = imageUrl.pathComponents.joined(separator: "-")
        
        if let image = memoryCache.getImage(forKey: keyUrl) {
            // 캐시에 이미지가 있는 경우
            print("메모리 불러오기 완료")
            completionHandler(image)
        } else if let image = diskCache.getImage(forKey: keyUrl) {
            // 캐시에 없는 경우 디스크 확인
            // 메모리 캐싱
            print("디스크 불러오기 완료")
            memoryCache.setImage(image, forKey: keyUrl)
            completionHandler(image)
        } else {
            // 메모리, 디스크 둘 다 없는 경우
            print("이미지 다운로드 및 등록")
            downloadImage(imageUrl: imageUrl, keyUrl: keyUrl) { image in
                completionHandler(image)
            }
        }
    }
    
    /// (메모리 전용) 이미지 로더
    func memoryloadImage(imageUrl url: String, completionHandler: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else { return }
        // 디스크 저장 가능한 형태로 키값 변경
        let keyUrl = imageUrl.pathComponents.joined(separator: "-")
        
        if let image = memoryCache.getImage(forKey: keyUrl) {
            // 캐시에 이미지가 있는 경우
            print("메모리 불러오기 완료")
            completionHandler(image)
        } else {
            // 메모리, 디스크 둘 다 없는 경우
            print("이미지 다운로드 및 등록")
            memoryDownloadImage(imageUrl: imageUrl, keyUrl: keyUrl) { image in
                completionHandler(image)
            }
        }
    }
    
    // 이미지 저장
    func setImage(image: UIImage, url: String) {
        guard let imageUrl = URL(string: url) else { return }
        // 디스크 저장 가능한 형태로 키값 변경
        let keyUrl = imageUrl.pathComponents.joined(separator: "-")
        
        // 메모리 캐싱
        memoryCache.setImage(image, forKey: keyUrl)
        // 디스크 캐싱
        diskCache.setImage(image, forKey: keyUrl)
        print("이미지 메모리, 디스크 캐싱 완료")
    }
    
    /// (메모리 전용) 이미지 저장
    func memorySetImage(image: UIImage, url: String) {
        guard let imageUrl = URL(string: url) else { return }
        // 디스크 저장 가능한 형태로 키값 변경
        let keyUrl = imageUrl.pathComponents.joined(separator: "-")
        // 메모리 캐싱
        memoryCache.setImage(image, forKey: keyUrl)
        print("이미지 메모리 캐싱 완료")
    }
    
    // 이미지 캐시 등록
    private func downloadImage(imageUrl: URL, keyUrl: String, completionHandler: @escaping (UIImage?) -> Void) {
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
                print("메모리 등록")
                self.memoryCache.setImage(downloadedImage, forKey: keyUrl)
                // 이미지 -> 디스크 캐시 등록
                print("디스크 등록")
                self.diskCache.setImage(downloadedImage, forKey: keyUrl)
                completionHandler(downloadedImage)
            }
        }.resume()
    }
    
    /// (메모리 전용) 이미지  캐시 등록
    private func memoryDownloadImage(imageUrl: URL, keyUrl: String, completionHandler: @escaping (UIImage?) -> Void) {
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
                print("메모리 등록")
                self.memoryCache.setImage(downloadedImage, forKey: keyUrl)
                completionHandler(downloadedImage)
            }
        }.resume()
    }
}

// MARK: - 메모리 캐싱
class MemoryCache {
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        print("메모리 불러오기 시도")
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
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                print("캐시 디렉토리 생성 완료: \(cacheDirectory.path)")
            } catch {
                print("캐시 디렉토리 생성 실패: \(error)")
            }
        }
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        do {
            try data.write(to: fileURL)
            print("이미지 저장 완료: \(fileURL.path)")
        } catch {
            print("이미지 저장 실패: \(error)")
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        print("디스크 불러오기 시도")
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: fileURL) else {
            print("이미지 불러오기 실패: 파일이 존재하지 않음")
            return nil
        }
        print("이미지 불러오기 성공: \(fileURL.path)")
        return UIImage(data: data)
    }
}

extension UIImageView {
    /// 캐시 이미지 불러오기
    func loadImage(url: String) {
        ImageCacheManager.shared.loadImage(imageUrl: url) { image in
            self.image = image
            print("extension 캐싱 완료")
        }
    }
    
    /// (메모리 전용) 캐시 이미지 불러오기
    func memoryloadImage(url: String) {
        ImageCacheManager.shared.memoryloadImage(imageUrl: url) { image in
            self.image = image
        }
    }
}