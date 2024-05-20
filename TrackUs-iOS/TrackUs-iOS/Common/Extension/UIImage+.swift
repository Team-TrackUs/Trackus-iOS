//
//  UIImage+.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/14/24.
//

import UIKit

extension UIImage {
    /// 이지지 사이즈 설정
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
}
