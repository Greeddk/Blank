//
//  Page.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct Page: Codable, Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID
    var fileId: UUID
    var sessions: [Session] = []// 전체 회차 sessions  / 특정 n회차 세션 접근 page.sessions.session
    var currentPageNumber: Int
    var basicWords: [BasicWord] = [] // [ (25,59,20,30) , (252,89,30,50) , ..... ]
    
    // TODO: - 삭제해야됨
    var basicWordCGRects: [CGRect]
}
