//
//  AspectFitImageView.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 7/8/24.
//

import UIKit

/// 사진 사이즈에 맞게 종횡 처리
class AspectFitImageView: UIImageView {
    // view 해당 이미지 가로세로 비율과 맞게 조정
    override var intrinsicContentSize: CGSize {
        if let image = image {
            let imageRatio = image.size.height / image.size.width
            let width = bounds.width
            let height = width * imageRatio
            return CGSize(width: width, height: height)
        }
        return super.intrinsicContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}
