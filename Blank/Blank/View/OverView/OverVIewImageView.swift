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
                ZStack {
                    Image(uiImage: overViewModel.currentImage ?? UIImage())  //경섭추가코드를 받기위한 변경
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: max(overViewModel.currentImage?.size.width ?? proxy.size.width, proxy.size.width),
                            height: max(overViewModel.currentImage?.size.height ?? proxy.size.height, proxy.size.height)
                        )
                    if overViewModel.isTotalStatsViewMode {
                        ForEach(Array(overViewModel.totalStats.keys), id: \.self) { key in
                            let rectOfKey = adjustRect(key, in: proxy)
                            
                            if let stat = overViewModel.totalStats[key] {
                                drawRectangle(with: key, color: getColor(rate: stat.correctRate), in: proxy)
                                    .overlay {
                                        if let word = overViewModel.allWords.first(where: { $0.rect == key }) {
                                            Text(word.wordValue)
                                                .font(.system(size: adjustRect(key, in: proxy).height / 1.9, weight: .semibold))
                                                .foregroundColor(stat.correctRate <= 0.4 ? .white : .black)
                                                .position(x: adjustRect(key, in: proxy).midX, y: adjustRect(key, in: proxy).midY)
                                                
                                        }
                                        if stat.isSelected {
                                            Image("PopoverShape")
                                                .resizable()
                                                .shadow(radius: 1)
                                                .opacity(0.7)
                                                .frame(width: 50, height: 45)
                                                .overlay(StatsText(stat: stat, proxy: proxy))
                                                .position(x: adjustRect(key, in: proxy).midX, y: adjustRect(key, in: proxy).origin.y + 45 - zoomScale * 5)
                                        }
                                    }
                                    .onTapGesture {
                                        overViewModel.totalStats[key]?.isSelected.toggle()
                                    }
                                    .zIndex(stat.isSelected ? 1 : 0)
                            }
                        }
                    } else if let currentSession = overViewModel.currentSession,
                              let words = overViewModel.wordsOfSession[currentSession.id] {
                        ForEach(words, id: \.id) { word in
                            Rectangle()
                                .fill(word.isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4))
                                .cornerRadius(3)
                                .frame(width: adjustRect(word.rect, in: proxy).width,
                                       height: adjustRect(word.rect, in: proxy).height)
                                .position(x: adjustRect(word.rect, in: proxy).midX,
                                          y: adjustRect(word.rect, in: proxy).midY)
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
        
        // 기기별 사이즈
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        var deviceX: CGFloat = 0.0
        
        var yValue = ( imageSize.height - rect.origin.y - rect.size.height) * scaleY
        
        switch (screenHeight ,screenWidth) {
        case (1366, 1024):
            // iPad Pro 12.9인치 모델 (1세대부터 6세대까지)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.55 )  + (rect.origin.x * scaleY))
        case (1194, 834):
            // iPad Pro 11인치 모델 (1세대부터 4세대까지)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.0 )  + (rect.origin.x * scaleY))
        case (1112, 834):
            // iPad Pro 10.5인치, iPad Air (3세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.48 )  + (rect.origin.x * scaleY))
        case (1080, 810):
            // iPad (7세대), iPad (8세대), iPad (9세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.25 )  + (rect.origin.x * scaleY))
        case (1180, 820):
            // iPad Air (4세대), iPad Air (5세대), iPad (10세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.9 )  + (rect.origin.x * scaleY))
        case (1024, 768):
            // iPad Pro 9.7인치, iPad (5세대), iPad (6세대), iPad mini (5세대) //여기만 좌표가 약간 안맞는데 최대한 조정한 것
            deviceX = ( ( (geometry.size.width - imageSize.width) / 1.95 )  + (rect.origin.x * scaleY))
            yValue = ( imageSize.height - rect.origin.y - rect.size.height) * scaleY + (imageSize.height * 0.004 )
        case (1133, 744):
            // iPad mini (6세대)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.8 )  + (rect.origin.x * scaleY))
        default:
            // 알 수 없는 또는 다른 해상도를 가진 모델 (12.9인치 모델을 deafult로 함)
            deviceX = ( ( (geometry.size.width - imageSize.width) / 6.5 )  + (rect.origin.x * scaleY))
        }
        
        
        return CGRect(
            x: deviceX  ,
            y:  yValue ,
            width: rect.width * scaleY,
            height : rect.height * scaleY
        )
    }
    
    func getColor(rate: Double) -> Color {
        switch rate {
        case 0.8...:
            return Color.blue0
        case 0.6..<0.8:
            return Color.blue1
        case 0.4..<0.6:
            return Color.blue2
        case 0.2..<0.4:
            return Color.blue3
        default:
            return Color.blue4
        }
    }
    
    // Rectangle 그리는 함수
    func drawRectangle(with key: CGRect, color: Color, in proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(color.shadow(.inner(color: .black.opacity(0.8),radius: 2, y: -1)))
            .cornerRadius(5)
            .shadow(color: .black.opacity(0.4), radius: 0, x: 1, y: 2)
            .frame(width: adjustRect(key, in: proxy).width,
                   height: adjustRect(key, in: proxy).height)
            .position(x: adjustRect(key, in: proxy).midX,
                      y: adjustRect(key, in: proxy).midY)
    }
    
    // Text를 그리는 뷰
    struct StatsText: View {
        var stat: WordStatistics
        var proxy: GeometryProxy
        
        var body: some View {
            VStack(spacing: 0) {
                Text("\(stat.correctSessionCount)/\(stat.totalSessionCount)")
                    .font(.system(size: 15))
                Text("(\(stat.correctRate.percentageTextValue(decimalPlaces: 0)))")
                    .font(.system(size: 12))
            }
        }
    }
    
}
