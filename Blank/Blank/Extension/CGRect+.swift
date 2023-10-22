//
//  CGRect+.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/19.
//

import UIKit
 
extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(width)
        hasher.combine(height)
    }
    
    /// Core Data에 저장하기 위해 세미콜론(;)으로 구분된 String 값
    var stringValue: String {
        "\(self.origin.x);\(self.origin.y);\(self.width);\(self.height)"
    }
    
    init?(stringValue: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let splittedValues = stringValue.split(separator: ";").map(String.init)
        guard splittedValues.count == 4,
              let x = numberFormatter.number(from: splittedValues[0]) as? CGFloat,
              let y = numberFormatter.number(from: splittedValues[1]) as? CGFloat,
              let width = numberFormatter.number(from: splittedValues[2]) as? CGFloat,
              let height = numberFormatter.number(from: splittedValues[3]) as? CGFloat else {
            return nil
        }
        
        self.init(x: x, y: y, width: width, height: height)
    }
}
