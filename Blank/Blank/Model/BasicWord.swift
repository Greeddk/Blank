//
//  BasicWord.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
//

import Foundation

struct BasicWord: Codable, Hashable, Identifiable {
    var id: UUID
    var wordValue: String
    var rect: CGRect
}
