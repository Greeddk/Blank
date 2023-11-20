//
//  ProgressStatusView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/16.
//

import SwiftUI

struct ProgressStatusView: View {
    @Binding var currentProgress: Double
    @State var message = "파일을 로딩 중 입니다."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: currentProgress)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text(message)
            
            Text("\(Int(currentProgress * 100))%") // 퍼센트로 변환하여 표시
        }
        .background(.white)
    }
}

#Preview {
    ProgressStatusView(currentProgress: .constant(0.5))
}
