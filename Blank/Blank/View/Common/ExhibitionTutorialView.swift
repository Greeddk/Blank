//
//  ExhibitionTutorialView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/26.
//

import SwiftUI

enum TutorialCategory {
    case homeView, overView, wordSelectView, ocrEditView, testPageView, resultView, cycledHomeView
    
    var imageName: String {
        return switch self {
        case .homeView:
            "Tutorial_1"
        case .overView:
            "Tutorial_2"
        case .wordSelectView:
            "Tutorial_3"
        case .ocrEditView:
            "Tutorial_4"
        case .testPageView:
            "Tutorial_5"
        case .resultView:
            "Tutorial_6"
        case .cycledHomeView:
            "Tutorial_7"
        }
    }
}

struct ExhibitionTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    let tutorialCategory: TutorialCategory
    
    var body: some View {
        ZStack {
            Image(tutorialCategory.imageName)
                .resizable()
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
    ExhibitionTutorialView(tutorialCategory: .homeView)
}
