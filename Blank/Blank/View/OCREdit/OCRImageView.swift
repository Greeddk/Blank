//
//  OCRImageView.swift
//  Blank
//
//  Created by 조용현 on 10/23/23.
//

import SwiftUI

struct OCRImageView: View {
    @StateObject var wordSelectViewModel: WordSelectViewModel
    @State var zoomScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { proxy in
            ZoomableContainer(zoomScale: $zoomScale) {
                // ScrollView를 통해 PinchZoom시 좌우상하 이동
                Image(uiImage: wordSelectViewModel.currentImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                    .resizable()
                    .scaledToFit()
                    .frame(
                        
                        width: max(wordSelectViewModel.currentImage?.size.width ?? proxy.size.width, proxy.size.width),
                        height: max(wordSelectViewModel.currentImage?.size.height ?? proxy.size.height, proxy.size.height)
                    )
                    .overlay {
                        // ForEach(page.sessions[0].words, id: \.self) { word in
                        ForEach(wordSelectViewModel.selectedWords.indices, id: \.self) { index in
                            let box = adjustRect(wordSelectViewModel.selectedWords[index].rect, in: proxy)
                            let real = wordSelectViewModel.selectedWords[index].id
                            TextView(name: $wordSelectViewModel.selectedWords[index].wordValue, height: box.height, width: box.width, orinX: real)
                                .position(CGPoint(x: box.origin.x + (box.width / 2), y: (box.origin.y + (box.height / 2 ))))
                        }
                    }
            }
        }
    }
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.wordSelectViewModel.currentImage?.size ?? CGSize(width: 1, height: 1)
        
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        return CGRect(
            
            
            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)),
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY,
            width: rect.width * scaleY,
            height : rect.height * scaleY
        )
    }
}
