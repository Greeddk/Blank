//
//  ScoringTestView.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
//

import SwiftUI

struct ScoringTestView: View {
    @StateObject var scoringViewModel = ScoringViewModel()
    @State var words: [Word] = [
        .init(id: .init(), sessionId: .init(), wordValue: "감귤", rect: .zero),
        .init(id: .init(), sessionId: .init(), wordValue: "금귤", rect: .zero),
        .init(id: .init(), sessionId: .init(), wordValue: "판다", rect: .zero),
        .init(id: .init(), sessionId: .init(), wordValue: "기린", rect: .zero),
    ]
    @State var result = ""
    
    var body: some View {
        VStack {
            Text(result)
        }.onAppear {
            let currentValues = ["감귤", "김귤", "판다", "기린"]
            scoringViewModel.initCurrentWritingValues(count: words.count)
            scoringViewModel.currentWritingValues = currentValues
            scoringViewModel.words = words
            scoringViewModel.score()
            result = scoringViewModel.words.map({ $0.isCorrect ? "O" : "X" }).joined()
            result += "\n\(scoringViewModel.correctRate)"
        }
    }
}

#Preview {
    ScoringTestView()
}
