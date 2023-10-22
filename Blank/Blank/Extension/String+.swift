//
//  String+.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/22.
//

import Foundation

extension String {
    var cgRect: CGRect? {
        CGRect(stringValue: self)
    }
}
