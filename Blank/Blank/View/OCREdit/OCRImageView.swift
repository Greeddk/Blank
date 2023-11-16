//
//  OCRImageView.swift
//  Blank
//
//  Created by 조용현 on 10/23/23.
//

import SwiftUI

struct OCRImageView: View {

    //    @State private var recognizedBoxes: [(String, CGRect)] = []
    //경섭추가코드
//    @State var words: [Word] = []

    @StateObject var wordSelectViewModel: WordSelectViewModel

    var body: some View {
        GeometryReader { proxy in
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            Image(uiImage: wordSelectViewModel.currentImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                .resizable()
                .scaledToFit()
                .frame(

                    width: max(wordSelectViewModel.currentImage?.size.width ?? proxy.size.width, proxy.size.width),
                    height: max(wordSelectViewModel.currentImage?.size.height ?? proxy.size.height, proxy.size.height)
                )
                .overlay {
                    if wordSelectViewModel.isOrginal == false {
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

    // ---------- Mark : 기존 반자동  코드  ----------------
//    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
//
//        let zoomScale: CGFloat = 1.0
//
//        let imageSize = self.wordSelectViewModel.currentImage?.size ?? CGSize(width: 1, height: 1)
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
        
        let zoomScale: CGFloat = 1.0
        let imageSize = self.wordSelectViewModel.currentImage?.size ?? CGSize(width: 1, height: 1)
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        let deviceModel = UIDevice.current.name
        var deviceX: CGFloat = 0.0
        
        switch deviceModel {
        case "iPad Pro (12.9-inch) (6th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)) * zoomScale
        case "iPad Pro (11-inch) (4th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.0 )  + (rect.origin.x * scaleY)) * zoomScale
        case "iPad (10th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.9 )  + (rect.origin.x * scaleY)) * zoomScale
        case "iPad Air (5th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.9 )  + (rect.origin.x * scaleY)) * zoomScale
        case "iPad mini (6th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.8 )  + (rect.origin.x * scaleY)) * zoomScale
        default:
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)) * zoomScale
        }
        
        
        return CGRect(
            x: deviceX  ,
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY * zoomScale ,
            width: rect.width * scaleY * zoomScale ,
            height : rect.height * scaleY * zoomScale
        )
    }
    
}
