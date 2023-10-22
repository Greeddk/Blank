//
//  Word.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct Word: Codable, Hashable {
    var id: UUID
    var wordValue: String
    var rect: CGRect
    var isCorrect: Bool = false
}
