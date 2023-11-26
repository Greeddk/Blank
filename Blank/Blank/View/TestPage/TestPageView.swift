//
//  TestView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct TestPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingModal = false
    @State private var showExhibitionModal = false
    @State var visionStart: Bool = false
    @State var type = ScribbleType.write
    @State private var hasTypeValueChanged = false
    @State private var goToResultPage = false
    var sessionNum: Int
    
    @StateObject var scoringViewModel: ScoringViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                testImage
                    .onTapGesture {
                        hideKeyboard()
                    }
//                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        showModalButton
                        goToNextPageButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.customToolbarBackgroundColor, for: .navigationBar)
            .navigationTitle("\(sessionNum)회차 시험지")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .background(Color.customViewBackgroundColor)
        }
        .navigationDestination(isPresented: $goToResultPage) {
            ResultPageView(scoringViewModel: scoringViewModel)
            
        }
        .ignoresSafeArea(.keyboard)
        // 쇼케이스 튜토리얼
        .fullScreenCover(isPresented: $showExhibitionModal) {
            ExhibitionTutorialManager.default.setEncountered(.testPageView)
        } content: {
            ExhibitionTutorialView(tutorialCategory: .testPageView)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(exhibitionHideTime)) {
                withoutAnimation {
                    showExhibitionModal = !ExhibitionTutorialManager.default.isEncountered(.testPageView)
                }
            }
        }
        
    }
    
    private var testImage: some View{
        // TODO: 시험볼 page에 textfield를 좌표에 만들어 보여주기
        TestPageImageView(uiImage: scoringViewModel.currentImage, words: $scoringViewModel.currentWritingWords)
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
        .buttonStyle(.bordered)
    }
    
    private var showModalButton: some View {
        Button {
            showingModal = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .sheet(isPresented: $showingModal) {
            ScribbleModalView()
        }
    }
    
    private var goToNextPageButton: some View {
        Button {
            goToResultPage = true
        } label: {
            Text("채점")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    TestPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
