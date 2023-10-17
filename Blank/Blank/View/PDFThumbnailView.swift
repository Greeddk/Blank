//
//  PdfThumbnailCardView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct PDFThumbnailView: View {
    var body: some View {
        VStack {
            Image("thumbnail")
                .frame(width: 200, height: 250)
            Spacer().frame(height: 15)
            Text("폰트의 해부학")
                .font(.title2)
                .fontWeight(.bold)
            Text("전체 페이지수: 182")
            Text("시험 본 페이지: 2")
        }
        .padding()
    }
}

#Preview {
    PDFThumbnailView()
}
