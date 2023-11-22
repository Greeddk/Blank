//
//  ImageView.swift
//  Blank
//
//  Created by 조용현 on 10/19/23.
//

import SwiftUI
import Vision

struct ImageView: View {
    //경섭추가코드
    var uiImage: UIImage?
    @Binding var visionStart:Bool
    @State private var recognizedBoxes: [(String, CGRect)] = []
    
    //경섭추가코드
    var viewName: String?
    
    //for drag gesture
    @State var startLocation: CGPoint?
    @State var endLocation: CGPoint?
    
    @Binding var isSelectArea: Bool
    
    // 다른 뷰에서도 사용할 수 있기 때문에 뷰모델로 전달하지 않고 개별 배열로 전달해봄
    @Binding var basicWords: [BasicWord]
    @Binding var targetWords: [Word]
    @Binding var currentWritingWords: [Word]
    
    @State var isAreaTouched: [Int: Bool] = [:]
    
    let cornerRadiusSize: CGFloat = 5
    let fontSizeRatio: CGFloat = 1.9
    
    @State var zoomScale: CGFloat = 1.0
    @State private var touchType: UITouch.TouchType = .pencil
    @State private var activeGestures: GestureMask = .all
    
    @Binding var movedCount: Int
    
    var body: some View {
        GeometryReader { proxy in
            imageWithOverlay(proxy)
                .modifier(TouchTypeModifier(touchType: $touchType))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if touchType != .pencil {
                                activeGestures = .subviews
                                startLocation = nil
                                endLocation = nil
                                return
                            }
                            
                            if startLocation == nil {
                                startLocation = value.location
                            }
                            
                            endLocation = value.location
                            
                            // 드래그 경로에 있는 단어 선택 1. rect구하기
                            let dragRect = CGRect(x: min(startLocation!.x, endLocation!.x),
                                                  y: min(startLocation!.y, endLocation!.y),
                                                  width: abs(endLocation!.x - startLocation!.x),
                                                  height: abs(endLocation!.y - startLocation!.y))
                            
                            for index in basicWords.indices {
                                if dragRect.intersects(adjustRect(basicWords[index].rect, in: proxy)) {
                                    basicWords[index].isSelectedWord = isSelectArea ? true : false
                                }
                            }
                        }
                        .onEnded{ value in
                            // drag 끝나면 초기화
                            startLocation = nil
                            endLocation = nil
                        }
                    , including: activeGestures)
            
        }
    }
    
    @ViewBuilder private func imageWithOverlay(_ proxy: GeometryProxy) -> some View {
        // ScrollView를 통해 PinchZoom시 좌우상하 이동
        Image(uiImage: uiImage ?? UIImage())  //경섭추가코드를 받기위한 변경
            .resizable()
            .scaledToFit()
        
        // GeometryReader를 통해 화면크기에 맞게 이미지 사이즈 조정
        
        //                이미지가 없다면 , 현재 뷰의 너비(GeometryReader의 너비)를 사용하고
        //                더 작은 값을 반환할건데
        //                이미지 > GeometryReader 일 때 이미지는 GeometryReader의 크기에 맞게 축소.
        //                반대로 GeometryReader > 이미지면  이미지의 원래 크기를 사용
            .frame(
                width: max(uiImage?.size.width ?? proxy.size.width, proxy.size.width) ,
                height: max(uiImage?.size.height ?? proxy.size.height, proxy.size.height)
            )
            .onChange(of: visionStart, perform: { newValue in
                if let image = uiImage {
                    recognizeText(from: image) { recognizedTexts  in
                        self.recognizedBoxes = recognizedTexts
                        basicWords = recognizedTexts.map { .init(id: UUID(), wordValue: $0.0, rect: $0.1, isSelectedWord: false) }
                    }
                    
                }
            })
        // 조조 코드 아래 일단 냅두고 위의 방식으로 수정했음
            .overlay {
                // TODO: Image 위에 올릴 컴포넌트(핀치줌 시 크기고정을 위해 width, height, x, y에 scale갑 곱하기)
                if viewName == "WordSelectView" {
                    if let start = startLocation, let end = endLocation {
                        Rectangle()
                            .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                            .frame(width: abs(end.x - start.x), height: abs(end.y - start.y))
                            .position(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
                        // .allowsHitTesting(touchType != .pencil)
                    }
                    ForEach(basicWords.indices, id: \.self) { index in
                        Rectangle()
                            .path(in: adjustRect(basicWords[index].rect, in: proxy))
                            .fill( basicWords[index].isSelectedWord  ? Color.green.opacity(0.4) : Color.white.opacity(0.01))
                            .onTapGesture {
                                withAnimation {
                                    basicWords[index].isSelectedWord = isSelectArea ? true : false
                                }
                            }
                    }
                    
                    
                    
                } else if viewName == "ResultPageView" {
                    // TargetWords의 wordValue에는 원래 값 + 맞고 틀림 여부(isCorrect)이 넘어온다
                    ForEach(targetWords.indices, id: \.self) { index in
                        let adjustRect = adjustRect(targetWords[index].rect, in: proxy)
                        let isCorrect = targetWords[index].isCorrect
                        let originalValue = targetWords[index].wordValue
                        let wroteValue = currentWritingWords[index].wordValue
                        
                        let correctColor = Color(red: 183 / 255, green: 255 / 255, blue: 157 / 255) // Color.green.opacity(0.4)
                        let wrongColor = Color(red: 253 / 255, green: 169 / 255, blue: 169 / 255) // Color.red.opacity(0.4)
                        let flippedAreaColor = Color(white: 238/255)
                        
                        RoundedRectangle(cornerSize: .init(width: cornerRadiusSize, height: cornerRadiusSize))
                            .path(in: adjustRect)
                            .fill(isCorrect ? correctColor : isAreaTouched[index, default: false] ? flippedAreaColor : wrongColor)
                            .shadow(color: isCorrect ? .clear : .black, radius: 2, x: 2, y: 2)
                            .overlay(
                                Text("\(isCorrect ? originalValue : isAreaTouched[index, default: false] ? originalValue : wroteValue)")
                                    .font(.system(size: adjustRect.height / fontSizeRatio, weight: .semibold))
                                    .offset(
                                        x: -(proxy.size.width / 2) + adjustRect.origin.x + (adjustRect.size.width / 2),
                                        y: -(proxy.size.height / 2) + adjustRect.origin.y + (adjustRect.size.height / 2)
                                    )
                            )
                            .onTapGesture {
                                // 기존 탭제스쳐 방식
                                if !targetWords[index].isCorrect {
                                    isAreaTouched[index, default: false].toggle()
                                }
                            }
                    }
                }
            }
            .onChange(of: touchType) { newValue in
                if viewName == "WordSelectView" {
                    if touchType == .pencil {
                        activeGestures = .all
                    } else {
                        activeGestures = .subviews
                    }
                } else {
                    activeGestures = .none
                }
            }
            .onChange(of: movedCount) { newValue in
                activeGestures = .all
            }
    }
    
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        
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
            
            
            //            x: ( ( (geometry.size.width - imageSize.width) / 3.5 )  + (rect.origin.x * scaleY))  ,
            x: deviceX  ,
            
            // 좌우반전
            //                x:  (imageSize.width - rect.origin.x - rect.size.width) * scaleX * scale ,
            
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY ,
            width: rect.width * scaleY ,
            height : rect.height * scaleY
        )
    }
    
    
    
    
}

//
//#Preview {
//    ImageView(scale: .constant(1.0))
//}
