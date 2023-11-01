//
//  Double.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/01.
//

import Foundation

extension Double {
    func percentageTextValue(max maxValue: Double = 1.0, decimalPlaces: Int = 2) -> String {
        guard self <= maxValue else {
            return ""
        }
        
        return .init(format: "%.\(decimalPlaces)f%%", (self / maxValue) * 100)
    }
}
