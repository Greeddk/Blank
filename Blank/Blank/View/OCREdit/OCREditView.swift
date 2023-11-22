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
    //    @Binding var isLinkActive: Bool
    // @Binding var generatedImage: UIImage?
    @State private var showingAlert = true
    @State var visionStart: Bool = false
    @State private var goToTestPage = false
    @State var isShowingButton = true
    var sessionNum: Int
    
    @StateObject var wordSelectViewModel: WordSelectViewModel
    
    @AppStorage(.tutorialOCREditView) var isEncounteredFirst = true
    
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
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                
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
            .toolbarBackground(.blue.opacity(0.2), for: .navigationBar)
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
        .background(Color(.systemGray4))
        .popup(isPresented: $showingAlert) {
            HStack {
                Image("pencil.and.scribble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundStyle(.white)
                    .padding()
                VStack {
                    Text("잘못 인식된 글자를 수정해주세요.")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                .padding()
            }
            .background(.black.opacity(0.8))
            .clipShape(.rect(cornerRadius: 10))
            .padding()
            .offset(y: 100)
        } customize: {
            $0
                .position(.topTrailing)
                .autohideIn(3.0)
                .closeOnTap(false) // 팝업을 터치했을 때 없애야 하나?
                .closeOnTapOutside(false)
                .animation(.smooth)
        }
        .sheet(isPresented: $isEncounteredFirst) {
            isEncounteredFirst = false
        } content: {
            TutorialModalView()
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
