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
            .toolbarBackground(.blue.opacity(0.2), for: .navigationBar)
            .navigationTitle("오타수정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .navigationDestination(isPresented: $goToTestPage) {
            TestPageView(
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
        .background(Color(.systemGray6))
        .popup(isPresented: $showingAlert) {
            HStack {
                Image("pencil.and.scribble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundStyle(.white)
                    .padding()
                VStack {
                    Text("Pencil을 활용해 빈칸을 채워보세요")
                        .font(.headline)
                        .foregroundStyle(.white)
                    HStack {
                        Text("자세한 내용은 우측 상단에")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.white)
                        Text("클릭해주세요")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
            .background(.black.opacity(0.8))
            .clipShape(.rect(cornerRadius: 10))
            .padding()
            .offset(x: 250, y: 100)
        } customize: {
            $0
                .position(.top)
                .autohideIn(3.0)
                .closeOnTap(false) // 팝업을 터치했을 때 없애야 하나?
                .closeOnTapOutside(false)
                .animation(.smooth)
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
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
//#Preview {
//    OCREditView(viewModel: OverViewModel(),isLinkActive: .constant(true))
//}
