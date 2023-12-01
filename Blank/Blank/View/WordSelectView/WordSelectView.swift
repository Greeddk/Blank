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
    @State var visionStart: Bool = false
    
    @State var goToOCRView = false
    @State var noneOfWordSelected = true
    
    // 더블탭, selectionView를 위한 상태변수
    @State private var selectedOption: String = "dragPen"
    @State var isSelectArea = true
    @State var isBlankArea = false
    
    var sessionNum: Int
    
    @ObservedObject var wordSelectViewModel: WordSelectViewModel
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack{
                    wordSelectImage
                    SelectionView(selectedOption: $selectedOption, isSelectArea: $isSelectArea, isBlankArea: $isBlankArea).position(
                        x: UIScreen.main.bounds.size.width * 0.9,
                        y: UIScreen.main.bounds.size.height * 0.03)
                    
                }
                
                
                PencilDobuleTapInteractionView {
                    // 이 클로저는 pencil 더블 탭 시 실행
                    self.pencilDoubleTapButtonAction(isSelectAreaBool: isSelectArea, isBlankAreaBool: isBlankArea)
                    
                }
                .frame(width: 0, height: 0)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    goToNextPageButton
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
    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        VStack {
            ImageView(uiImage: wordSelectViewModel.currentImage, visionStart: $visionStart, viewName: "WordSelectView", isSelectArea: $isSelectArea, isBlankArea: $isBlankArea, basicWords: $wordSelectViewModel.basicWords, targetWords: .constant([]), currentWritingWords: .constant([]), selectedOption: $selectedOption )
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
    
    func pencilDoubleTapButtonAction(isSelectAreaBool: Bool, isBlankAreaBool: Bool) {
        withAnimation{
            switch (isSelectAreaBool, isBlankAreaBool) {
            case (false, true):
                selectedOption = "dragPen" // 프레임 -> 드래그 버튼이 솟아오르게 변경
                isSelectArea = true
                isBlankArea = false
            case (true, false):
                selectedOption = "eraser" // 드래그 -> 지우개 버튼이 솟아오르게 변경
                isSelectArea = false
                isBlankArea = false
            case (false, false):
                selectedOption = "framPen" // 지우개 -> 프레임 버튼이 솟아오르게 변경
                isSelectArea = false
                isBlankArea = true
            default:
                isSelectArea = false
                isBlankArea = true
            }
        }
    }
}


#Preview {
    HomeView()
}
