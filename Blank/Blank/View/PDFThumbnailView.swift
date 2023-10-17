//
//  PdfThumbnailCardView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct PDFThumbnailView: View {
    @State var file: File
    
    var body: some View {
        VStack {
            Image("thumbnail")
                .frame(width: 200, height: 250)
            Spacer().frame(height: 15)
            Text("\(file.fileName)")
                .font(.title2)
                .fontWeight(.bold)
            Text("전체 페이지수: \(file.totalPageCount)")
            Text("시험 본 페이지: \(file.pages.count)")
        }
        .padding()
        .onAppear {
            
        }
    }
}

#Preview {
    PDFThumbnailView(file: DUMMY_FILE)
}
