//
//  ColorExtension.swift
//  Blank
//
//  Created by Greed on 11/21/23.
//

import SwiftUI

extension Color {
    // resultpage에서 버튼에 사용되는 컬러
    static let correctColor = Color(hex: "AEF894")
    static let wrongColor = Color(hex: "FDA5A5")
    static let flippedAreaColor = Color(hex: "EEEEEE")
    // 오버뷰에서 전체통계에 사용되는 컬러
    static let blue0 = Color.white //   정답률 : 80~100 일때 컬러
    static let blue1 = Color(hex: "E1F5FE") // 정답률 : 60~80 일때 컬러
    static let blue2 = Color(hex: "81D4FA") // 정답률 : 40~60 일때 컬러
    static let blue3 = Color(hex: "049BE5") // 정답률 : 20~40 일때 컬러
    static let blue4 = Color(hex: "00579B") // 정답률 : 0~20 일때 컬러
    
    static let customToolbarBackgroundColor = Color.blue.opacity(0.2)
    static let customViewBackgroundColor = Color(.systemGray4)
    static let statViewBackgroundColor = Color(.systemGray2).opacity(0.6)

}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

