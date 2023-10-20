//
//  Session.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct Session: Codable, Hashable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var words: [Word] = []
    var correctCount: Int {
        return words.filter { $0.isCorrect }.count
    }
}


