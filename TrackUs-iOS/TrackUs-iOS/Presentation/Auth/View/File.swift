//
//  File.swift
//  TrackUs-iOS
//
//  Created by 최주원 on 5/17/24.
//

import UIKit

// MARK: - 프로필 공개 view
class ProfilePublicView: UIView {
    
    var delegate: MainButtonEnabledDelegate?
    
    /// 버튼 활성화 확인용
    func buttonEnabled() -> Bool {
        return true
    }
}
