//
//  ImageView.swift
//  Blank
//
//  Created by 조용현 on 10/19/23.
//

import SwiftUI

struct ImageView: View {
    var image: String = ""
    @Binding var scale: CGFloat

    var body: some View {
        GeometryReader { proxy in
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            ScrollView([.horizontal, .vertical]) {
                Image(image)
                    .resizable()
                // GeometryReader를 통해 화면크기에 맞게 이미지 사이즈 조정
                    .frame(width: proxy.size.width * scale, height: proxy.size.height * scale)
                    .scaledToFit()
                    .clipShape(Rectangle())
                    .overlay {
                        // TODO: Image 위에 올릴 컴포넌트(핀치줌 시 크기고정을 위해 width, height, x, y에 scale갑 곱하기)
                    }
            }
        }
    }
}

#Preview {
    ImageView(scale: .constant(1.0))
}
