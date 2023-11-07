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
    @Binding var visionStart: Bool
    
    @StateObject var overViewModel: OverViewModel
    //경섭추가코드
    @State var zoomScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { proxy in
            ZoomableContainer(zoomScale: $zoomScale) {
                // ScrollView를 통해 PinchZoom시 좌우상하 이동
                Image(uiImage: overViewModel.currentImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: max(overViewModel.currentImage?.size.width ?? proxy.size.width, proxy.size.width),
                        height: max(overViewModel.currentImage?.size.height ?? proxy.size.height, proxy.size.height)
                    )
                
                // 통계가 나타나는 부분
                    .overlay {
                        // TODO: Image 위에 올릴 컴포넌트(핀치줌 시 크기고정을 위해 width, height, x, y에 scale갑 곱하기)
                        if overViewModel.isTotalStatsViewMode {
                            ZStack(alignment: .top) {
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
                                ForEach(Array(overViewModel.totalStats.keys), id: \.self) { key in
                                    if let stat = overViewModel.totalStats[key] {
                                        OverViewStatsView(width: proxy.size.width / 15, height: proxy.size.height / 15, zoomScale: zoomScale)
                                            .overlay{
                                                Text("5/10")
                                                    .font(.system(size: proxy.size.width / 40 / zoomScale))
                                            }
                                            .position(x: adjustRect(key, in: proxy).origin.x + 20, y: adjustRect(key, in: proxy).origin.y + 40)
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
    }
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = overViewModel.currentImage?.size ?? CGSize(width: 1, height: 1)
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        
        return CGRect(
            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY)),
            
            // 좌우반전
            //                x:  (imageSize.width - rect.origin.x - rect.size.width) * scaleX * scale ,
            
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY,
            width: rect.width * scaleY,
            height : rect.height * scaleY
        )
    }
    
    // => recognizeTextTwo는 OverViewModel로 이동하였습니다.
}

//
//#Preview {
//    ImageView(scale: .constant(1.0))
//}
