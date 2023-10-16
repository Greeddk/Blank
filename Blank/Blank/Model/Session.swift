//
//  Session.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct Session {
    var words:[Word] = []
    var correctCount: Int {
        return words.filter { $0.correct }.count
    }
}


