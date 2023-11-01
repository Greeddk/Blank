//
//  SessionStatistics.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/01.
//

import Foundation

struct SessionStatistics: Codable {
    var correctCount: Int
    var totalCount: Int
    
    var correctRate: Double {
        Double(correctCount) / Double(totalCount)
    }
}
