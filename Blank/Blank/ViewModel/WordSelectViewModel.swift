//
//  WordSelectViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
//

import Foundation

class WordSelectViewModel: ObservableObject {
    @Published var basicWords: [BasicWord] = []
    @Published var selectedWords: [Word] = []
    @Published var page: Page
    @Published var session: Session
    
    init(page: Page, basicWords: [BasicWord] = []) {
        self.page = page
        self.basicWords = basicWords
        // 새로운 세션
        self.session = .init(id: UUID(), pageId: page.id)
    }
}
