//
//  WordStatistics.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/01.
//

import Foundation

struct WordStatistics: Codable, Identifiable {
    var id: CGRect
    
    var correctSessionCount: Int
    var totalSessionCount: Int
    var isSelected: Bool = false
    
    var isAllCorrect: Bool {
        correctSessionCount == totalSessionCount
    }
    
    var correctRate: Double {
        Double(correctSessionCount) / Double(totalSessionCount)
    }
}
