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
    
    @State var goToOCRView = false
    
    @State var isSelectArea = true
    @State var noneOfWordSelected = true
    @State var isBlankArea = true

    @ObservedObject var wordSelectViewModel: WordSelectViewModel
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                wordSelectImage
                Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
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
                        makeBlankButton

                        // segment 버튼
//                        Picker("도구 선택", selection: $isSelectArea) {
//                            Image(systemName: "arrow.rectanglepath")
//                                .symbolRenderingMode(.monochrome)
//                                .foregroundStyle(.black)
//                                .tag(true)
//                            
//                            Image(systemName: "eraser.line.dashed.fill")
//                                .symbolRenderingMode(.monochrome)
//                                .foregroundStyle(.black)
//                                .tag(false)
//                        }
//                        .id(isSelectArea)
//                        .tint(.red)
//                        .pickerStyle(.segmented)
                        

                        goToNextPageButton
                        
                    }
                    
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
            OCREditView(wordSelectViewModel: wordSelectViewModel)
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
            ImageView(uiImage: wordSelectViewModel.currentImage, visionStart: $visionStart, viewName: "WordSelectView", isSelectArea: $isSelectArea, isBlankArea: $isBlankArea, basicWords: $wordSelectViewModel.basicWords, targetWords: .constant([]), currentWritingWords: .constant([]))
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
    //MARK: 수동으로 빈칸 만들기 제어 버튼
    private var makeBlankButton: some View {
        Button {
            isBlankArea.toggle()
        } label: {
//            Image(systemName: "chevron.left")
            isBlankArea ? Text("blank") : Text("Off")
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


#Preview {
    HomeView()
}
