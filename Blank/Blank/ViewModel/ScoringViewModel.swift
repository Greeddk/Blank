//
//  ScoringViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/24.
//

import Foundation

final class ScoringViewModel: ObservableObject {
    /*
     문제 풀이: 푼 것과 정답을 비교
     맞으면 isCorrect = true
     
     배열이므로 순서가 같다고 가정 =>
     currentWritingValues에는 입력하는 값들
     words는 세션의 words 를 대입
     == 반드시 == initCurrentWritingValues을 words.count와 동일하게 설정해야 합니다.
     */
    
    @Published var page: Page
    /// 현재 풀고있는 단어들
    @Published var currentWritingWords: [Word] = []
    /// 정답 단어들
    @Published var targetWords: [Word] = []
    
    init(page: Page, currentWritingWords: [Word] = [], targetWords: [Word] = []) {
        self.page = page
        self.currentWritingWords = currentWritingWords
        self.targetWords = targetWords
    }
    
    func score() {
        print("[DEBUG]",  #function,currentWritingWords.count, targetWords.count)
        guard currentWritingWords.count == targetWords.count else {
            print("[DEBUG] currentWritingValues.count와 targetWords.count가 같아야 채점할 수 있습니다.")
            return
        }
        
        currentWritingWords.enumerated().forEach { (index, currentWord) in
            let targetWordIndex = targetWords.firstIndex(where: { $0.id == currentWord.id })!
            print("[DEBUG]", currentWord.wordValue, targetWords[targetWordIndex].wordValue)
            print("[DEBUG]", targetWords[targetWordIndex].isCorrect)
            
            // 채점 로직: 
            // 1) 채점시에는 대소문자 구분없이 글자만 같으면 정답으로 처리한다.
            // 2) 띄어쓰기 입력은 받되 채점시 고려안함
            let currentWordValue = currentWord.wordValue
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
            let targetWordValue = targetWords[targetWordIndex].wordValue
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
            targetWords[targetWordIndex].isCorrect = currentWordValue == targetWordValue
        }
    }
    
    /// 워드의 ID를 찾아 해당 워드값을 새값으로 바꿈
    func changeTargetWordValue(id: UUID, newValue: String) {
        guard let index = currentWritingWords.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        currentWritingWords[index].wordValue = newValue
    }
    
    var correctCount: Int {
        // print("[DEBUG] \(Date())", words)
        // words.reduce(0, { $0 + ($1.isCorrect ? 1 : 0) })
        return targetWords.reduce(0, { $0 + ($1.isCorrect ? 1 : 0) })
    }
    
    var totalWordCount: Int {
        targetWords.count
    }
    
    var correctRate: Double {
        Double(correctCount) / Double(totalWordCount)
    }

    var correctRateTextValue: String {
        return String(format: "%.1f%%", correctRate * 100)
    }
}
