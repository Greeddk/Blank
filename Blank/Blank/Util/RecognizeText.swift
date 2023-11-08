//
//  RecognizeText.swift
//  Blank
//
//  Created by Sup on 11/7/23.
//

import SwiftUI
import Vision

// completion은 recognizeText함수자체가 이미지에서 텍스트를 인식하는 비동기 작업을 수행하니까
// 함수가 종료되었을 때가 아닌 작업이 완료되었을때 completion클로저를 호출해야됨
func recognizeText(from image: UIImage, completion: @escaping ([(String, CGRect)]) -> Void) {
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
                    // 동일한 순서의 글자(중복단어)가 있을경우 각 단어별로 고유한 좌표를 위한 세팅
                    var currentPosition = topCandidate.string.startIndex
                    
                    for word in words {
                        // 단어의 시작과 끝 위치를 찾습니다.
                        if let wordRange = topCandidate.string.range(of: String(word),
                                                                     range: currentPosition..<topCandidate.string.endIndex) {
                            
                            // 현재 위치를 다음 단어 검색을 위해 업데이트합니다.
                            currentPosition = wordRange.upperBound
                            
                            if let box = try? topCandidate.boundingBox(for: wordRange) {
                                let boundingBox = VNImageRectForNormalizedRect(box.boundingBox,
                                                                               Int(image.size.width),
                                                                               Int(image.size.height))
                                
                                let changeFalotingToIntBox = CGRect(x: Int(round(boundingBox.origin.x)),
                                                                    y: Int(round(boundingBox.origin.y)),
                                                                    width: Int(round(boundingBox.width)),
                                                                    height: Int(round(boundingBox.height))
                                )
                                
                                
                                recognizedTexts.append((String(word), changeFalotingToIntBox))
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
