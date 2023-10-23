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
    
    @StateObject var scoringViewModel = ScoringViewModel()
    @StateObject var overViewModel: OverViewModel
    
    @Binding var page: Page
    
    var body: some View {
        NavigationStack {
            VStack {
                testImage
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backBtn
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        showModalBtn
                        nextBtn
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .navigationTitle("시험")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(.systemGray6))
        .onAppear {
            // ⭐️⭐️⭐️⭐️⭐️⭐️ 세션의 Words를 scoringViewModel.words 에 대입
            scoringViewModel.words = [
                .init(id: .init(), sessionId: .init(), wordValue: "감귤", rect: .zero),
                .init(id: .init(), sessionId: .init(), wordValue: "금귤", rect: .zero),
                .init(id: .init(), sessionId: .init(), wordValue: "판다", rect: .zero),
                .init(id: .init(), sessionId: .init(), wordValue: "기린", rect: .zero),
            ]
            scoringViewModel.currentWritingValues = ["감귤", "김귤", "판다", "가란"]
            scoringViewModel.score()
            
        }
    }
    
    private var testImage: some View{
        // TODO: 시험볼 page에 textfield를 좌표에 만들어 보여주기
        
        TestPagePinchZoomView(image: generatedImage, page: $page)
        //        PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]), overViewModel: overViewModel)
        
    }
    
    private var backBtn: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var showModalBtn: some View {
        Button {
            showingModal = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .sheet(isPresented: $showingModal) {
            ScrribleModalView(selectedType: $type, hasTypeValueChanged: $hasTypeValueChanged)
        }
    }
    
    private var nextBtn: some View {
        NavigationLink(destination:
                        ResultPageView(isLinkActive: $isLinkActive, generatedImage: $generatedImage, scoringViewModel: scoringViewModel, overViewModel: overViewModel)) {
            Text("채점")
                .fontWeight(.bold)
        }
                        .onTapGesture {
                            // TODO: 채점하기 로직
                        }
    }
}

//#Preview {
//    TestPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
