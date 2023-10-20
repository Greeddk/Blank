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
}
