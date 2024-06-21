//
//  String+.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 5/21/24.
//

import Foundation

extension String {
    var asNumber: Int {
        guard let number = Int(self) else { return 0 }
        return number
    }
}
