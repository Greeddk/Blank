//
//  Test.swift
//  MacroView
//
//  Created by Greed on 10/15/23.
//

import SwiftUI

struct CorrectInfoView: View {
    @StateObject var scoringViewModel: ScoringViewModel
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.4)
            HStack {
                // TODO: 정답률, 문제개수, 정답개수 받아오기
                Spacer()
                Text("정답률: \(scoringViewModel.correctRateTextValue)%")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Spacer()
                Text("문제: \(scoringViewModel.totalWordCount)개")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Spacer()
                Text("정답: \(scoringViewModel.correctCount)개")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}

#Preview {
    CorrectInfoView(scoringViewModel: .init())
}
