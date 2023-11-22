//
//  TutorialModalView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/22.
//

import SwiftUI

struct TutorialModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State var imageAssetName: String = "myImage"
    @ObservedObject var playerViewModel: PlayerViewModel = PlayerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("손글씨 입력 쓰기")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)
                    .padding()
                Image(imageAssetName)
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
            .interactiveDismissDisabled()
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("완료")
        }
    }
}


#Preview {
    TutorialModalView()
}
