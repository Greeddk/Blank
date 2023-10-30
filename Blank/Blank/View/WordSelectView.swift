//
//  WordSelectView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct WordSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = true
    @Binding var isLinkActive: Bool
    @State var visionStart: Bool = false
    @Binding var generatedImage: UIImage?
    
    @State var goToOCRView = false
    // @State var basicWords: [BasicWord] = []
    @State var page: Page
    
    @StateObject var overViewModel: OverViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                wordSelectImage
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
            }
            .alert("단어를 터치해 주세요" ,isPresented: $showingAlert) {
                Button("확인", role: .cancel) {
                    
                }
            } message: {
                Text("시험을 보고싶은 단어를 터치해주세요")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    goToNextPageButton
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("단어선택")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(.systemGray6))
        .navigationDestination(isPresented: $goToOCRView) {
            OCREditView(isLinkActive: $isLinkActive, generatedImage: $generatedImage, overViewModel: overViewModel, page: $page)
        }
        
    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        VStack {
            PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: $page.basicWords, viewName: "WordSelectView", overViewModel: overViewModel,page: $page)
        }
        
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var goToNextPageButton: some View {
        Button {
            // TODO: 선택된 단어를 배열로 저장
            var words: [Word] = []
            for w in overViewModel.basicWords.filter({ $0.isSelectedWord }) {
                words.append(Word(id: UUID(), sessionId: page.sessions[0].id, wordValue: w.wordValue, rect: w.rect))
            }
            page.sessions[0].words = words
            goToOCRView = true
        } label: {
            Text("다음")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
}


#Preview {
    HomeView().environmentObject(HomeViewModel())
}
