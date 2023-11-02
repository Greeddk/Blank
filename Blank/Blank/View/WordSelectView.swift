//
//  WordSelectView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI
import PopupView

struct WordSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = true
    @State var visionStart: Bool = false
    @Binding var generatedImage: UIImage?
    
    @State var goToOCRView = false
    
    @ObservedObject var wordSelectViewModel: WordSelectViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                wordSelectImage
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    goToNextPageButton
                }
            }
            .toolbarBackground(.blue.opacity(0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("단어선택")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(.systemGray6))
        .navigationDestination(isPresented: $goToOCRView) {
            OCREditView(generatedImage: $generatedImage, wordSelectViewModel: wordSelectViewModel)
        }
        .popup(isPresented: $showingAlert) {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundStyle(.white)
                    .padding()
                VStack {
                    Text("단어를 터치해 주세요.")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    Text("시험을 보고싶은 단어를 터치해주세요")
                        .foregroundStyle(.white)
                }
                .padding()
            }
            .background(.black.opacity(0.8))
            .clipShape(.rect(cornerRadius: 10))
            .padding()
            .offset(x: 0, y: 100)
        } customize: {
            $0
                .position(.top)
                .autohideIn(3.0)
                .closeOnTap(false) // 팝업을 터치했을 때 없애야 하나?
                .closeOnTapOutside(false)
                .animation(.smooth)
        }
    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        VStack {
            ImageView(uiImage: generatedImage, visionStart: $visionStart, zoomScale: .constant(1.0), viewName: "WordSelectView", basicWords: $wordSelectViewModel.basicWords, targetWords: .constant([]), currentWritingWords: .constant([]))
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
            for w in wordSelectViewModel.basicWords.filter({ $0.isSelectedWord }) {
                words.append(Word(id: UUID(), sessionId: wordSelectViewModel.session.id, wordValue: w.wordValue, rect: w.rect))
            }
            wordSelectViewModel.selectedWords = words
            goToOCRView = true
        } label: {
            Text("다음")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
}


#Preview {
    HomeView()
}
