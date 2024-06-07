//
//  UIImage+.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/14/24.
//

import UIKit

extension UIImage {
    /// 사이즈 설정
    func resize(width: CGFloat, height: CGFloat) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: width, height: height).integral
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .high
        draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 이미지 전체 비율 조정 - 용량 줄이기
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    /// 이미지 캡처
    static func imageFromView(view: UIView) -> UIImage? {
            // bitmap 이미지 컨텍스트 생성
               UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
               view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
               defer { UIGraphicsEndImageContext() }
               guard let context = UIGraphicsGetCurrentContext() else { return nil }
               view.layer.render(in: context)
               let image = UIGraphicsGetImageFromCurrentImageContext()
               return image
           }
}
