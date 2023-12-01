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
    @Binding var isBlankArea: Bool
    
    // 다른 뷰에서도 사용할 수 있기 때문에 뷰모델로 전달하지 않고 개별 배열로 전달해봄
    @Binding var basicWords: [BasicWord]
    @Binding var targetWords: [Word]
    @Binding var currentWritingWords: [Word]
    
    @Binding var selectedOption: String
    
    @State var isAreaTouched: [Int: Bool] = [:]
    
    let cornerRadiusSize: CGFloat = 5
    let fontSizeRatio: CGFloat = 1.9
    
    @State var zoomScale: CGFloat = 1.0
    
    @State private var checkViewSize: CGSize = .zero
    
    
    
    var body: some View {
        GeometryReader { proxy in
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
                        }
                        ForEach(basicWords.indices, id: \.self) { index in
                            Rectangle()
                                .path(in: adjustRect(basicWords[index].rect, in: proxy))
                                .fill( basicWords[index].isSelectedWord  ? Color.green.opacity(0.4) : Color.white.opacity(0.01))
                                .onTapGesture {
                                    withAnimation {
                                        
                                        if selectedOption == "eraser"{
                                            basicWords[index].isSelectedWord = false
                                        } else if selectedOption == "dragPen" {
                                            basicWords[index].isSelectedWord = true
                                        }
                                        
                                        //                                        basicWords[index].isSelectedWord = isSelectArea ? false : true
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
                            
                            
                            RoundedRectangle(cornerSize: .init(width: cornerRadiusSize, height: cornerRadiusSize))
                                .path(in: adjustRect)
                                .fill(isCorrect ? Color.correctColor.shadow(.inner(color: .clear,radius: 0, y: 0)) : isAreaTouched[index, default: false] ? Color.flippedAreaColor.shadow(.inner(color: .black.opacity(0.5),radius: 2, y: -1)) : Color.wrongColor.shadow(.inner(color: .black.opacity(0.5),radius: 2, y: -1)))
                                .shadow(color: isCorrect ? .clear : .black.opacity(0.7), radius: 0, x: 1, y: 2)
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
            
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            if startLocation == nil {
                                startLocation = value.location
                            }
                            
                            endLocation = value.location
                            
                            // ---------- Mark : 기존 단어 드래그시 선택 코드  ----------------
                            // 드래그 경로에 있는 단어 선택 1. rect구하기
                            
                            if !isBlankArea {
                                buttonTypeAction(isBlankAreaBool: self.isBlankArea,
                                                 isSelectAreaBool: self.isSelectArea,
                                                 startLocation: startLocation,
                                                 endLocation: endLocation,
                                                 proxy: proxy)
                            }
                        }
                        .onEnded{ value in
                            
                            
                            
                            let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
                            let leftSpacerWidth = frameRatio().0
                            let rightSpacerWidth = frameRatio().1
                            endLocation!.x = max(leftSpacerWidth, endLocation!.x)
                            endLocation!.x = min(rightSpacerWidth, endLocation!.x)
                            
                            
                            
                            // 드레그 완료 후 빈칸 BasicWord 배열에 추가
                            if isBlankArea {
                                buttonTypeAction(isBlankAreaBool: self.isBlankArea,
                                                 isSelectAreaBool: self.isSelectArea,
                                                 startLocation: startLocation,
                                                 endLocation: endLocation,
                                                 proxy: proxy)
                            }
                            
                            // drag 끝나면 초기화
                            startLocation = nil
                            endLocation = nil
                        }
                )
            
            
            
            
        }
        
    }
    
    
    // ---------- Mark : 반자동   ----------------
    func adjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        
        
        // Image 뷰 너비와 UIImage 너비 사이의 비율
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        // 기기별 사이즈
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        var deviceFactor: CGFloat = 0.0
        
        switch (screenHeight ,screenWidth) {
            // iPad Pro 12.9인치 모델 (1세대부터 6세대까지)
        case (1366, 1024): deviceFactor = 6.5
            // iPad Pro 11인치 모델 (1세대부터 4세대까지)
        case (1194, 834): deviceFactor = 7.0
            // iPad Pro 10.5인치, iPad Air (3세대)
        case (1112, 834): deviceFactor = 4.5
            // iPad (7세대), iPad (8세대), iPad (9세대)
        case (1080, 810): deviceFactor = 4.0
            // iPad Air (4세대), iPad Air (5세대), iPad (10세대)
        case (1180, 820): deviceFactor = 7.0
            // iPad Pro 9.7인치, iPad (5세대), iPad (6세대), iPad mini (5세대)
        case (1024, 768): deviceFactor = 3.43
            // iPad mini (6세대)
        case (1133, 744): deviceFactor = 15.0
            // 알 수 없는 또는 다른 해상도를 가진 모델 (12.9인치 모델을 deafult로 함)
        default: deviceFactor = 6.5
        }
        
        
        let deviceX = ( ( (geometry.size.width - imageSize.width) / deviceFactor )  + (rect.origin.x * scaleY))
        
        return CGRect(
            x: deviceX,
            y:( imageSize.height - rect.origin.y - rect.size.height) * scaleY ,
            width: rect.width * scaleY ,
            height : rect.height * scaleY
        )
    }
    
    // ---------- Mark : 조조 프레임 생성  ----------------
    //MARK: adjustRect 함수 reverse
    func reverseAdjustRect(_ rect: CGRect, in geometry: GeometryProxy) -> CGRect {
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        let scaleY: CGFloat = geometry.size.height / imageSize.height
        
        // screenSize와 deviceFactor 계산
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        var deviceFactor: CGFloat = 0.0
        // deviceFactor 역산에 필요한 디바이스별 설정 (adjustRect 함수에서 사용된 로직에 따라)
        switch (screenHeight ,screenWidth) {
            // iPad Pro 12.9인치 모델 (1세대부터 6세대까지)
        case (1366, 1024): deviceFactor = 6.5
            // iPad Pro 11인치 모델 (1세대부터 4세대까지)
        case (1194, 834): deviceFactor = 7.0
            // iPad Pro 10.5인치, iPad Air (3세대)
        case (1112, 834): deviceFactor = 4.5
            // iPad (7세대), iPad (8세대), iPad (9세대)
        case (1080, 810): deviceFactor = 4.0
            // iPad Air (4세대), iPad Air (5세대), iPad (10세대)
        case (1180, 820): deviceFactor = 7.0
            // iPad Pro 9.7인치, iPad (5세대), iPad (6세대), iPad mini (5세대)
        case (1024, 768): deviceFactor = 3.43
            // iPad mini (6세대)
        case (1133, 744): deviceFactor = 15.0
            // 알 수 없는 또는 다른 해상도를 가진 모델 (12.9인치 모델을 deafult로 함)
        default: deviceFactor = 6.5
        }
        
        let deviceX = (rect.origin.x - (geometry.size.width - imageSize.width) / deviceFactor) / scaleY
        
        return CGRect(
            x: deviceX,
            y: (imageSize.height - (rect.origin.y / scaleY) - (rect.size.height / scaleY)),
            width: rect.width / scaleY,
            height: rect.height / scaleY
        )
    }
    
    func frameRatio() -> (CGFloat, CGFloat) {
        
        
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let imageSize = self.uiImage?.size ?? CGSize(width: 1, height: 1)
        let diffSize = UIScreen.main.bounds.width - imageSize.width
        
        
        var leftSpacerWidth: CGFloat = 0.0
        var rightSpacerWidth: CGFloat = 0.0
        
        switch (screenHeight ,screenWidth) {
            // iPad Pro 12.9인치 모델 (1세대부터 6세대까지)
        case (1366, 1024):
            leftSpacerWidth = diffSize * 0.15
            rightSpacerWidth = diffSize * 2.239
            
            // iPad Pro 11인치 모델 (1세대부터 4세대까지)
        case (1194, 834):
            leftSpacerWidth = diffSize * 0.147
            rightSpacerWidth = diffSize * 3.369
            
            // iPad Pro 10.5인치, iPad Air (3세대)
        case (1112, 834):
            leftSpacerWidth = diffSize * 0.216
            rightSpacerWidth = diffSize * 3.289
            
            //            // iPad (7세대), iPad (8세대), iPad (9세대)
        case (1080, 810):
            leftSpacerWidth = diffSize * 0.238
            rightSpacerWidth = diffSize * 3.55
            
            //            // iPad Air (4세대), iPad Air (5세대), iPad (10세대)
        case (1180, 820):
            leftSpacerWidth = diffSize * 0.133
            rightSpacerWidth = diffSize * 3.531
            
            //            // iPad Pro 9.7인치, iPad (5세대), iPad (6세대), iPad mini (5세대)
        case (1024, 768):
            leftSpacerWidth = diffSize * 0.29
            rightSpacerWidth = diffSize * 4.18
            
            // iPad mini (6세대)
        case (1133, 744):
            leftSpacerWidth = diffSize * 0.054
            rightSpacerWidth = diffSize * 4.95
            
            //            // 알 수 없는 또는 다른 해상도를 가진 모델 (12.9인치 모델을 deafult로 함)
        default:
            leftSpacerWidth = diffSize * 0.15
            rightSpacerWidth = diffSize * 2.239
        }
        
        return (leftSpacerWidth, rightSpacerWidth)
        
    }
    
    
    //    func buttonTypeAction(isBlankAreaBool: Bool, isSelectAreaBool: Bool, index: Int) {
    func buttonTypeAction(isBlankAreaBool: Bool, isSelectAreaBool: Bool ,startLocation: CGPoint?, endLocation: CGPoint?, proxy: GeometryProxy) {
        
        // 기본 drag 위치정보얻기
        let dragRect = CGRect(x: min(startLocation!.x, endLocation!.x),
                              y: min(startLocation!.y, endLocation!.y),
                              width: abs(endLocation!.x - startLocation!.x),
                              height: abs(endLocation!.y - startLocation!.y))
        
        switch (isSelectAreaBool, isBlankAreaBool) {
            //framPen 모드일 때
        case (false, true):
            
            let dragword = BasicWord(id: UUID(),
                                     wordValue: "",
                                     rect: reverseAdjustRect(dragRect, in: proxy),
                                     isSelectedWord: true)
            basicWords.append(dragword)
            
            
            //dragPen 모드일 때
        case (true, false):
            for index in basicWords.indices {
                if dragRect.intersects(adjustRect(basicWords[index].rect, in: proxy)) {
                    basicWords[index].isSelectedWord =  true
                }
            }
            
            //eraser 모드일 때
        case (false, false):
            
            // .reversed()로 순회하면서 하는 이유는 뒤에서진행하면서 index문제없게 처리하려고
            basicWords.indices.reversed().forEach { index in
                if dragRect.intersects(adjustRect(basicWords[index].rect, in: proxy)) {
                    if basicWords[index].wordValue == "" {
                        basicWords.remove(at: index)
                    } else {
                        basicWords[index].isSelectedWord = false
                    }
                }
            }
            
        default:
            let _ = "nothing"
        }
        
    }
}


//#Preview {
//    ImageView(scale: .constant(1.0))
//}
