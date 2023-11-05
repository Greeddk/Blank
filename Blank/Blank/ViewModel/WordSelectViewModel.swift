//
//  WordSelectViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
//

import UIKit

class WordSelectViewModel: ObservableObject {
    @Published var basicWords: [BasicWord] = []
    @Published var selectedWords: [Word] = []
    @Published var page: Page
    @Published var session: Session
    @Published var currentImage: UIImage?
    
    init(page: Page, basicWords: [BasicWord] = [], currentImage: UIImage? = nil) {
        self.page = page
        self.basicWords = basicWords
        self.currentImage = currentImage
        // 새로운 세션
        self.session = .init(id: UUID(), pageId: page.id)
    }
    
    /// 새로운 답안 작성 공간 생성
    var writingWords: [Word] {
        selectedWords.map { .init(id: $0.id, sessionId: $0.sessionId, wordValue: "", rect: $0.rect) }
    }
}
