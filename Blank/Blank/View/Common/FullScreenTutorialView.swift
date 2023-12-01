//
//  ExhibitionTutorialView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/26.
//

import SwiftUI

enum TutorialCategory {
    case homeView, overView, wordSelectView, ocrEditView, testPageView, resultView, cycledOverView
    
    var imageName: String {
        return switch self {
        case .homeView:
            "Tutorial_HomeView"
        case .overView:
            "Tutorial_OverView"
        case .wordSelectView:
            "Tutorial_WordSelectView"
        case .ocrEditView:
            "Tutorial_OCREditView"
        case .testPageView:
            "Tutorial_TestPageView"
        case .resultView:
            "Tutorial_ResultView"
        case .cycledOverView:
            "Tutorial_OverView_Cycle"
        }
    }
    
    var keyName: String {
        return "cfgEncountered_\(imageName)"
    }
}

struct FullScreenTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    let tutorialCategory: TutorialCategory
    
    var body: some View {
        ZStack {
            Image(tutorialCategory.imageName)
                .resizable()
                .frame(width: UIScreen.main.bounds.width)
            // TODO: - 쇼케이스용 임시 오버레이로 해상도는 12.9 고정
            Button {
                withoutAnimation {
                    dismiss()
                }
            } label: {
                Label("이해했어요", systemImage: "checkmark.square")
                    .font(.title)
                    .frame(width: 218, height: 45)
            }
            .buttonStyle(.borderedProminent)
            .offset(y: 350)
            .tint(.exhibitionButton)
        }
    }
}

#Preview {
    FullScreenTutorialView(tutorialCategory: .homeView)
}
