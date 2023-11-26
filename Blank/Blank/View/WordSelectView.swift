//
//  WordSelectView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct WordSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showExhibitionModal = false
    @State var visionStart: Bool = false
    
    @State var goToOCRView = false
    
    @State var isSelectArea = true
    @State var noneOfWordSelected = true
    var sessionNum: Int
    
    @ObservedObject var wordSelectViewModel: WordSelectViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                wordSelectImage
                
//                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                
                PencilDobuleTapInteractionView {
                    // 이 클로저는 pencil 더블 탭 시 실행
                    self.isSelectArea.toggle()
                    
                }
                .frame(width: 0, height: 0)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                    HStack{
                        
                        // segment 버튼
                        Picker("도구 선택", selection: $isSelectArea) {
                            Image(systemName: "arrow.rectanglepath")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.black)
                                .tag(true)
                            
                            Image(systemName: "eraser.line.dashed.fill")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.black)
                                .tag(false)
                        }
                        .id(isSelectArea)
                        .tint(.red)
                        .pickerStyle(.segmented)
                        
                        
                        goToNextPageButton
                        
                    }
                    
                }
            }
            .toolbarBackground(Color.customToolbarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("단어 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.customViewBackgroundColor)
        .navigationDestination(isPresented: $goToOCRView) {
            OCREditView(sessionNum: sessionNum, wordSelectViewModel: wordSelectViewModel)
        }
        // 쇼케이스 튜토리얼
        .fullScreenCover(isPresented: $showExhibitionModal) {
            ExhibitionTutorialManager.default.setEncountered(.wordSelectView)
        } content: {
            ExhibitionTutorialView(tutorialCategory: .wordSelectView)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(exhibitionHideTime)) {
                withoutAnimation {
                    showExhibitionModal =  !ExhibitionTutorialManager.default.isEncountered(.wordSelectView)
                }
            }
        }
    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        VStack {
            ImageView(uiImage: wordSelectViewModel.currentImage, visionStart: $visionStart, viewName: "WordSelectView", isSelectArea: $isSelectArea, basicWords: $wordSelectViewModel.basicWords, targetWords: .constant([]), currentWritingWords: .constant([]))
        }
        .onChange(of: wordSelectViewModel.basicWords) { _ in
            noneOfWordSelected = !wordSelectViewModel.basicWords.contains(where: { $0.isSelectedWord })
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
        .buttonStyle(.bordered)
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
        .disabled(noneOfWordSelected)
    }
    
}

//
//#Preview {
//    HomeView()
//}
