//
//  PdfThumbnailCardView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct PDFThumbnailView: View {
    @State var file: File
    @State var thumbnail = Image("thumbnail")
    
    var body: some View {
        VStack {
            thumbnail
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
            prepareThumbnail(from: file.fileURL)
        }
    }
}

extension PDFThumbnailView {
    private func prepareThumbnail(from url: URL) {
        guard let thumbnail = generateThumbnail(of: .init(width: 200, height: 250), for: url, atPage: 0) else {
            return
        }
        
        self.thumbnail = Image(uiImage: thumbnail)
    }
}

#Preview {
    PDFThumbnailView(file: DUMMY_FILE)
}
