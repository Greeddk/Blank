//
//  ScoringViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/24.\
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
    
    // @Published var currentWritingValues: [String] = []
    @Published var currentWritingWords: [Word] = []
    @Published var targetWords: [Word] = []
    
    // func initCurrentWritingValues(count: Int) {
    //     currentWritingValues = .init(repeating: "", count: count)
    // }
    
    func score() {
        print("[DEBUG]",  #function,currentWritingWords.count, targetWords.count)
        guard currentWritingWords.count == targetWords.count else {
            print("[DEBUG] currentWritingValues.count와 targetWords.count가 같아야 채점할 수 있습니다.")
            return
        }
        
        currentWritingWords.enumerated().forEach { (index, currentWord) in
            print("[DEBUG]", #function, index, currentWord)
            // words[index].isCorrect = currentValue == words[index].wordValue
            let targetWordIndex = targetWords.firstIndex(where: { $0.id == currentWord.id })!
            print("[DEBUG]", currentWord.wordValue, targetWords[targetWordIndex].wordValue)
            print("[DEBUG]", targetWords[targetWordIndex].isCorrect)
            targetWords[targetWordIndex].isCorrect = currentWord.wordValue == targetWords[targetWordIndex].wordValue
        }
    }
    
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
        "\(correctRate * 100)%"
    }
}
