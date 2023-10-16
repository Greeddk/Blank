//
//  Page.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct Page {
    var sessions: [Session] = []// 전체 회차 sessions  / 특정 n회차 세션 접근 page.sessions.session
    var currentPageNumber: Int
    var basicWordCGRect: [CGRect] // [ (25,59,20,30) , (252,89,30,50) , ..... ]
}

