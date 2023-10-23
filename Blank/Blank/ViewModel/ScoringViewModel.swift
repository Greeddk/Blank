//
//  ScoringViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
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
    
    @Published var currentWritingValues: [String] = []
    @Published var words: [Word] = []
    
    func initCurrentWritingValues(count: Int) {
        currentWritingValues = .init(repeating: "", count: count)
    }
    
    func score() {
        guard currentWritingValues.count == words.count else {
            print("currentWritingValues.count와 words.count가 같아야 채점할 수 있습니다.")
            return
        }
        
        currentWritingValues.enumerated().forEach { (index, currentValue) in
            words[index].isCorrect = currentValue == words[index].wordValue
        }
    }
    
    var correctCount: Int {
        words.reduce(0, { $0 + ($1.isCorrect ? 1 : 0) })
    }
    
    var correctRate: Double {
        Double(correctCount) / Double(words.count)
    }
    
    var correctRateTextValue: String {
        "\(correctRate * 100)"
    }
}
