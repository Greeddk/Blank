//
//  CDRect+.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/20.
//

import Foundation

extension CDRect {
    var textDescription: String {
        "{x: \(self.x), y: \(self.y), width: \(self.width), height: \(self.height)}"
    }
    
    var cgRect: CGRect {
        .init(x: CGFloat(self.x), y: CGFloat(self.y), width: CGFloat(self.width), height: CGFloat(self.height))
    }
}
