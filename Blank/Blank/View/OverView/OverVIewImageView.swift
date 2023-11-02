//
//  OverVIewImageView.swift
//  Blank
//
//  Created by Sup on 10/24/23.
//

import SwiftUI
import Vision

struct OverViewImageView: View {
    //경섭추가코드
    // var uiImage: UIImage?
    @Binding var visionStart: Bool
    // @State private var recognizedBoxes: [(String, CGRect)] = []
    
    @StateObject var overViewModel: OverViewModel
    //경섭추가코드
    @Binding var zoomScale: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            // ScrollView를 통해 PinchZoom시 좌우상하 이동
            Image(uiImage: overViewModel.currentImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                .resizable()
                .scaledToFit()
                .frame(
                    width: max(overViewModel.currentImage?.size.width ?? proxy.size.width, proxy.size.width) * zoomScale,
                    height: max(overViewModel.currentImage?.size.height ?? proxy.size.height, proxy.size.height) * zoomScale
                )
                
                // 조조 코드 아래 일단 냅두고 위의 방식으로 수정했음
                .overlay {
                    // TODO: Image 위에 올릴 컴포넌트(핀치줌 시 크기고정을 위해 width, height, x, y에 scale갑 곱하기)
                    if overViewModel.isTotalStatsViewMode {
                        ForEach(Array(overViewModel.totalStats.keys), id: \.self) { key in
                            if let stat = overViewModel.totalStats[key] {
                                Rectangle()
                                    .path(in: adjustRect(key, in: proxy))
                                    .fill(stat.isAllCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                                    .onTapGesture {
                                        overViewModel.totalStats[key]?.isSelected = true
                                    }
                            }
                        }
                    } else if let currentSession = overViewModel.currentSession,
                                let words = overViewModel.wordsOfSession[currentSession.id] {
                        ForEach(words, id: \.id) { word in
                            Rectangle()
                                .path(in: adjustRect(word.rect, in: proxy))
                                .fill(word.isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                        }
                    }
                    
                }
        }
    }
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = overViewModel.currentImage?.size ?? CGSize(width: 1, height: 1)
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        //        let scaleX: CGFloat = geometry.size.width / imageSize.width
        
        //        print("----------------")
        //        print("imageSize.width: \(imageSize.width) , imageSize.height: \(imageSize.height)" )
        //        print("geometry.size.width: \(geometry.size.width) , geometry.size.height: \(geometry.size.width)")
        //        print("scaleX: \(scaleX) , scaleY: \(scaleY) , scale: \(zoomScale)")
        //        print("rect.origin.x: \(rect.origin.x) , rect.origin.y: \(rect.origin.y)")
        //        print("rect.size.width: \(rect.size.width) , rect.size.height: \(rect.size.height)")
        //        print("----------------")
        
        
        return CGRect(
            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))   *  zoomScale   ,
            
            // 좌우반전
            //                x:  (imageSize.width - rect.origin.x - rect.size.width) * scaleX * scale ,
            
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY * zoomScale ,
            width: rect.width * scaleY * zoomScale,
            height : rect.height * scaleY * zoomScale
        )
    }
    
    // => recognizeTextTwo는 OverViewModel로 이동하였습니다.
}

//
//#Preview {
//    ImageView(scale: .constant(1.0))
//}
