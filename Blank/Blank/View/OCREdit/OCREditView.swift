//
//  OCREditView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OCREditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingModal = false
    @State private var showExhibitionModal = false
    @State var visionStart: Bool = false
    @State private var goToTestPage = false
    @State var isShowingButton = true
    var sessionNum: Int
    
    @StateObject var wordSelectViewModel: WordSelectViewModel
    
    /*
     전단계 WordSelectView에서 단어를 선택하면
     해당 단어 목록은 현재 Session 內 Words에 들어가야 할 것 같음
     */
    
    var body: some View {
        NavigationStack {
            VStack {
                ocrEditImage
                    .onTapGesture {
                        hideKeyboard()
                    }
//                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        backButton
                        showOriginalImageButton
                    }
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
            .navigationTitle("오타 수정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .navigationDestination(isPresented: $goToTestPage) {
            TestPageView(
                sessionNum: sessionNum, 
                scoringViewModel: .init(
                    page: wordSelectViewModel.page,
                    session: wordSelectViewModel.session,
                    currentWritingWords: wordSelectViewModel.writingWords,
                    targetWords: wordSelectViewModel.selectedWords,
                    currentImage: wordSelectViewModel.currentImage
                )
            )
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.customViewBackgroundColor)
        // 쇼케이스 튜토리얼
        .fullScreenCover(isPresented: $showExhibitionModal) {
            ExhibitionTutorialManager.default.setEncountered(.ocrEditView)
        } content: {
            ExhibitionTutorialView(tutorialCategory: .ocrEditView)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(exhibitionHideTime)) {
                withoutAnimation {
                    showExhibitionModal = !ExhibitionTutorialManager.default.isEncountered(.ocrEditView)
                }
            }
        }
        
    }
    
    private var ocrEditImage: some View {
        // TODO: 텍스트필드를 사진 위에 올려서 확인할 텍스트와 함께 보여주기
        OCRImageView(wordSelectViewModel: wordSelectViewModel)
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
            showingModal.toggle()
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .sheet(isPresented: $showingModal) {
            
            ScribbleModalView()
            
        }
    }
    
    private var goToNextPageButton: some View {
        Button {
            goToTestPage = true
        } label: {
            
            Text("시험보기")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var showOriginalImageButton: some View {
        Button {
            wordSelectViewModel.isOrginal.toggle()
        } label: {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.gray.opacity(0.2))
                .frame(width: 40, height: 35)
                .overlay {
                    if wordSelectViewModel.isOrginal {
                        Text("빈칸")
                    } else {
                        Text("원본")
                    }
                }
        }
    }
}

//#Preview {
//    OCREditView(viewModel: OverViewModel(),isLinkActive: .constant(true))
//}
