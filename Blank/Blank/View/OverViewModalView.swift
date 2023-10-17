//
//  OverViewModalView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OverViewModalView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(0..<10) {_ in
                    NavigationLink(destination: OverView()) {
                        // TODO: 기기에 따라 크기 조정 및 하단 정보들 넣기
                        PDFThumbnailView()
                    }
                    .foregroundColor(.black)
                }
            }
            .padding()
        }
    }
}

#Preview {
    OverViewModalView()
}
