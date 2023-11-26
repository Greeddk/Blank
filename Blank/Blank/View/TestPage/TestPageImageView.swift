//
//  TestPageImageView.swift
//  Blank
//
//  Created by 조용현 on 10/24/23.
//

import SwiftUI

struct TestPageImageView: View {
    
    var uiImage: UIImage?
    //    @State private var recognizedBoxes: [(String, CGRect)] = []
    //경섭추가코드
    @State var zoomScale: CGFloat = 1.0
    @Binding var words: [Word]
    
    var body: some View {
        GeometryReader { proxy in
            ZoomableContainer(zoomScale: $zoomScale) {
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            Image(uiImage: uiImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                .resizable()
                .scaledToFit()
                .frame(
                    
                    width: max(uiImage?.size.width ?? proxy.size.width, proxy.size.width),
                    height: max(uiImage?.size.height ?? proxy.size.height, proxy.size.height)
                )
                .overlay {
                    // ForEach(page.sessions[0].words, id: \.self) { word in
                    ForEach(words.indices, id: \.self) { index in
                        let box = adjustRect(words[index].rect, in: proxy)
                        TextView(name: $words[index].wordValue, height: box.height, width: box.width, orinX: words[index].id)
                            .position(CGPoint(x: box.origin.x + (box.width / 2), y: (box.origin.y + (box.height / 2 ))))
                        
                        //                            TextView(name: w.wordValue ,height: $height, width: $width, scale: $zoomScale, page: $page, originX: $real)
                        //                                .position(CGPoint(x: (originX + (width/2)), y: (originY + (height/2))))
                    }
                }
        }
        }
    }
    
    // ---------- Mark : 반자동   ----------------
//    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
//        
//        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
//        
//        let scaleY: CGFloat = geometry.size.height / imageSize.height
//        
//        return CGRect(
//            
//            
//            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)) * zoomScale,
//            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY * zoomScale,
//            width: rect.width * scaleY * zoomScale,
//            height : rect.height * scaleY * zoomScale
//        )
//    }
    
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        // 기기별 사이즈
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        var deviceX: CGFloat = 0.0
        
        switch (screenHeight ,screenWidth) {
        case (1366, 1024):
            // iPad Pro 12.9인치 모델 (1세대부터 6세대까지)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 6.5 )  + (rect.origin.x * scaleY))
        case (1194, 834):
            // iPad Pro 11인치 모델 (1세대부터 4세대까지)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 7.0 )  + (rect.origin.x * scaleY))
        case (1112, 834):
            // iPad Pro 10.5인치, iPad Air (3세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 4.5 )  + (rect.origin.x * scaleY))
        case (1080, 810):
            // iPad (7세대), iPad (8세대), iPad (9세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 4.0 )  + (rect.origin.x * scaleY))
        case (1180, 820):
            // iPad Air (4세대), iPad Air (5세대), iPad (10세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 7.0 )  + (rect.origin.x * scaleY))
        case (1024, 768):
            // iPad Pro 9.7인치, iPad (5세대), iPad (6세대), iPad mini (5세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))
        case (1133, 744):
            // iPad mini (6세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 20.0 )  + (rect.origin.x * scaleY))
        default:
            // 알 수 없는 또는 다른 해상도를 가진 모델 (12.9인치 모델을 deafult로 함)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 6.5 )  + (rect.origin.x * scaleY))
        }
        
        
        return CGRect(
            x: deviceX  ,
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY,
            width: rect.width * scaleY ,
            height : rect.height * scaleY
        )
    }
    
    
}

//#Preview {
//    TestPageImageView()
//}
