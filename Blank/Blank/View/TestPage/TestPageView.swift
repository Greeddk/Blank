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
    @Binding var isLinkActive: Bool
    @Binding var generatedImage: UIImage?
    @State var visionStart: Bool = false
    @State var type = ScrribleType.write
    @State private var hasTypeValueChanged = false
    @State private var goToResultPage = false
    
    @StateObject var overViewModel: OverViewModel
    
    // @State var page: Page
    @Binding var page: Page
    
    @StateObject var scoringViewModel = ScoringViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                testImage
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
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
            .toolbarBackground(.white, for: .navigationBar)
            .navigationTitle("시험")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .navigationDestination(isPresented: $goToResultPage) {
            ResultPageView(isLinkActive: $isLinkActive, generatedImage: $generatedImage, scoringViewModel: scoringViewModel, overViewModel: overViewModel, page: $page)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(.systemGray6))
        .onAppear {
            scoringViewModel.currentWritingWords = page.sessions[0].words.map { Word(id: $0.id, sessionId: $0.id, wordValue: "", rect: $0.rect) }
            scoringViewModel.targetWords = page.sessions[0].words
        }
    }
    
    private var testImage: some View{
        // TODO: 시험볼 page에 textfield를 좌표에 만들어 보여주기
        TestPagePinchZoomView(image: generatedImage, page: $page, scoringViewModel: scoringViewModel)
//        PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]), overViewModel: overViewModel)
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var showModalButton: some View {
        Button {
            showingModal = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .sheet(isPresented: $showingModal) {
            ScrribleModalView(selectedType: $type, hasTypeValueChanged: $hasTypeValueChanged)
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
