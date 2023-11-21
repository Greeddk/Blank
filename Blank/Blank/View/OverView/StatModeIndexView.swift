//
//  StatModeIndex.swift
//  Blank
//
//  Created by Greed on 11/21/23.
//

import SwiftUI

struct StatModeIndexView: View {
    var correctRate: [Int] = [0,20,40,60,80]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("통계 정답률 구분")
                .foregroundColor(.black)
            
            ForEach(correctRate, id: \.self) { rate in
                HStack {
                    Rectangle()
                        .fill(getColor(rate: Double(rate)))
                        .cornerRadius(5)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 1)
                        .frame(width: 30, height: 10)
                    Text("\(rate)% ~ \(rate+20)%")
                        .font(.caption2)
                }
            }
        }
        .frame(width: 150)
        .background(.white.opacity(0.5))
    }
    
    func getColor(rate: Double) -> Color {
        switch rate {
        case 80...:
            return Color.white
        case 60..<80:
            return Color.blue1
        case 40..<60:
            return Color.blue2
        case 20..<40:
            return Color.blue3
        default:
            return Color.blue4
        }
    }
    
}

#Preview {
    StatModeIndexView()
}
