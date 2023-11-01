//
//  OverVIewImageView.swift
//  Blank
//
//  Created by Sup on 10/24/23.
//

import SwiftUI
import Vision

struct OverVIewImageView: View {
    //경섭추가코드
    var uiImage: UIImage?
    @Binding var visionStart:Bool
    @State private var recognizedBoxes: [(String, CGRect)] = []
    
    @StateObject var overViewModel: OverViewModel
    //경섭추가코드
    @Binding var zoomScale: CGFloat
    
    
    @Binding var basicWords: [BasicWord]
    
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
                .onChange(of: visionStart, perform: { newValue in
                    if let image = uiImage {
                        recognizeTextTwo(from: image) { recognizedTexts in
                            self.recognizedBoxes = recognizedTexts
                            basicWords = recognizedTexts.map { .init(id: UUID(), wordValue: $0.0, rect: $0.1, isSelectedWord: false) }
                            //                                for (text, rect) in recognizedTexts {
                            //                                    print("Text: \(text), Rect: \(rect)")
                            //                                }
                        }
                        
                        
                    }
                    
                    //                        print("Recognized boxes: \(self.recognizedBoxes)")
                    
                })
            
            // 조조 코드 아래 일단 냅두고 위의 방식으로 수정했음
        }
    }
    
    // completion은 recognizeText함수자체가 이미지에서 텍스트를 인식하는 비동기 작업을 수행하니까
    // 함수가 종료되었을 때가 아닌 작업이 완료되었을때 completion클로저를 호출해야됨
    func recognizeTextTwo(from image: UIImage, completion: @escaping ([(String, CGRect)]) -> Void) {
        // 이미지 CGImage로 받음
        guard let cgImage = image.cgImage else { return }
        // VNImageRequestHandler옵션에 URL로 경로 할 수도 있고 화면회전에 대한 옵션도 가능
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // 텍스트 인식 작업이 완료되었을때 실행할 클로저 정의
        let request = VNRecognizeTextRequest { (request, error) in
            var recognizedTexts: [(String, CGRect)] = [] // 단어랑 좌표값담을 빈 배열 튜플 생성
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                for observation in results {
                    if let topCandidate = observation.topCandidates(1).first {
                        let words = topCandidate.string.split(separator: " ")
                        
                        for word in words {
                            if let range = topCandidate.string.range(of: String(word)) {
                                if let box = try? topCandidate.boundingBox(for: range) {
                                    let boundingBox = VNImageRectForNormalizedRect(box.boundingBox, Int(image.size.width), Int(image.size.height))
                                    recognizedTexts.append((String(word), boundingBox))
                                }
                            }
                        }
                    }
                }
            }
            completion(recognizedTexts)
        }
        
        request.recognitionLanguages = ["ko-KR"]
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.01
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing text recognition request: \(error)")
        }
    }
    
    
}

//
//#Preview {
//    ImageView(scale: .constant(1.0))
//}
