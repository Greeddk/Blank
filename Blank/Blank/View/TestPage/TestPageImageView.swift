//
//  TestPageImageView.swift
//  Blank
//
//  Created by 조용현 on 10/24/23.
//

import SwiftUI

struct TestPageImageView: View {
    
    var uiImage: UIImage?
    @State private var recognizedBoxes: [(String, CGRect)] = []
    //경섭추가코드
    @Binding var zoomScale: CGFloat
    @Binding var page: Page
    
    var body: some View {
        GeometryReader { proxy in
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            Image(uiImage: uiImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                .resizable()
                .scaledToFit()
                .frame(
                    
                    width: max(uiImage?.size.width ?? proxy.size.width, proxy.size.width) * zoomScale,
                    height: max(uiImage?.size.height ?? proxy.size.height, proxy.size.height) * zoomScale
                )
                .overlay {
                    ForEach(page.sessions[0].words, id: \.self) { word in
                        let box = adjustRect(word.rect, in: proxy)
                        @State var width = box.width
                        @State var height = box.height
                        @State var originX = box.origin.x
                        @State var originY = box.origin.y
                        
                        TextView(name: word.wordValue, height: $height, width: $width, scale: $zoomScale)
                            .position(CGPoint(x: (originX + (width/2)), y: (originY + (height/2))))
                    }
                }
            
        }
    }
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        return CGRect(
            
            
            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)) * zoomScale,
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY * zoomScale,
            width: rect.width * scaleY * zoomScale,
            height : rect.height * scaleY * zoomScale
        )
    }
}

//#Preview {
//    TestPageImageView()
//}
