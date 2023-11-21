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
                            if let stat = overViewModel.totalStats[key] {
                                @State var isSelected = false
                                drawRectangle(with: key, color: getColor(rate: stat.correctRate), in: proxy)
                                    .overlay {
                                        if stat.isSelected {
                                            Image("PopoverShape")
                                                .resizable()
                                                .shadow(radius: 1)
                                                .opacity(0.7)
                                                .frame(width: proxy.size.width / 30, height: proxy.size.height / 40)
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
                            drawRectangle(with: word.rect, color: word.isCorrect ? Color.green.opacity(0.4) : Color.red.opacity(0.4), in: proxy)
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
        let deviceModel = UIDevice.current.name
        var deviceX: CGFloat = 0.0
        
        switch deviceModel {
        case "iPad Pro (12.9-inch) (6th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))
        case "iPad Pro (11-inch) (4th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.0 )  + (rect.origin.x * scaleY))
        case "iPad (10th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.9 )  + (rect.origin.x * scaleY))
        case "iPad Air (5th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.9 )  + (rect.origin.x * scaleY))
        case "iPad mini (6th generation)":
            deviceX = ( ( (geometry.size.width - imageSize.width) / 2.8 )  + (rect.origin.x * scaleY))
        default:
            deviceX = ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))
        }
        
        
        return CGRect(
            x: deviceX  ,
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY,
            width: rect.width * scaleY,
            height : rect.height * scaleY
        )
    }
    
    func getColor(rate: Double) -> Color {
        switch rate {
        case 0.8...:
            return Color.white
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
            .fill(color)
            .cornerRadius(5)
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
                    .font(.system(size: proxy.size.height / 100))
                Text("(\(stat.correctRate.percentageTextValue(decimalPlaces: 0)))")
                    .font(.system(size: proxy.size.height / 150))
            }
        }
    }
    
}
