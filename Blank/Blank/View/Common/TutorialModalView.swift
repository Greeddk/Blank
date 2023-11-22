//
//  TutorialModalView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/22.
//

import SwiftUI

struct TutorialModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State var imageAssetNames: [String] = [
        "myImage",
        "thumbnail",
        "checkedCheckmark",
    ]
    @State private var assetNameIndex = 0
    @State private var enableCloseButton = false
    @ObservedObject var playerViewModel: PlayerViewModel = PlayerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $assetNameIndex) {
                    ForEach(imageAssetNames.indices, id: \.self) { index in
                        VStack {
                            Text(imageAssetNames[index])
                                .font(.largeTitle)
                                .bold()
                                .padding(.top, 50)
                            .padding()
                            Image(imageAssetNames[index])
                                .resizable()
                                .scaledToFit()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                        .disabled(!enableCloseButton)
                }
            }
            .onChange(of: assetNameIndex) {
                if $0 + 1 == imageAssetNames.count {
                    enableCloseButton = true
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
