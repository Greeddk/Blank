//
//  OverViewPinchZoomView.swift
//  Blank
//
//  Created by Sup on 10/24/23.
//

import SwiftUI

struct OverViewPinchZoomView: View {

    // Image 정보를 받을 수 있도록 프로퍼티 추가 - 경섭
    var image: UIImage?
    @Binding var visionStart:Bool
    @Binding var basicWords: [BasicWord]
    
    
    @StateObject var overViewModel: OverViewModel
    
    //
    @State private var scale: CGFloat = 1.0
    @State var lastScale: CGFloat = 1.0
    private let minScale = 1.0
    private let maxScale = 5.0

    var magnification: some Gesture {
        // PinchZoom Gesture
        MagnificationGesture()
        // 확대 시작 시
            .onChanged { state in
                adjustScale(from: state)
            }
        // 확대 종료 시
            .onEnded { state in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
            }
    }

    var body: some View {
        // ImageView를 불러와서 Gesture 적용
        OverVIewImageView(uiImage: image, visionStart: $visionStart, overViewModel: overViewModel, zoomScale: $scale, basicWords: $basicWords )
            .gesture(magnification)
    }
    // 변경값을 lastScale에 저장하여 다음 확대시 lastScale에서부터 시작
    func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        scale *= delta
        lastScale = state
    }
    func getMinimumScaleAllowed() -> CGFloat {
        return max(scale, minScale)
    }
    func getMaximumScaleAllowed() -> CGFloat {
        return min(scale, maxScale)
    }
    // 확대 Scale min(1.0), max(3.0) 설정
    func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }
}

//#Preview {
//    PinchZoomView()
//}


