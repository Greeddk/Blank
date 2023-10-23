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
    
    // @State var basicWords: [BasicWord] = []
    @State var page: Page
    
    var body: some View {
        NavigationStack {
            VStack {
                wordSelectImage
            }
            .alert("단어를 터치해 주세요" ,isPresented: $showingAlert) {
                Button("확인", role: .cancel) {
                    
                }
            } message: {
                Text("시험을 보고싶은 단어를 터치해주세요")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backBtn
                }
                ToolbarItem(placement: .topBarTrailing) {
                    nextBtn
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("단어선택")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(.systemGray6))
        .onAppear {
            // print("WordSelectView's basicWords.", page)
        }

    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        VStack {
            // ForEach(basicWords, id: \.id) { basicWord in
            //     Text("\(basicWord.wordValue), \(basicWord.rect.debugDescription)")
            // }
            PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: $page.basicWords)
        }
        
    }
    
    private var backBtn: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var nextBtn: some View {
        NavigationLink(destination: OCREditView(isLinkActive: $isLinkActive, generatedImage: $generatedImage, page: page)) {
            Text("다음")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 선택된 단어를 배열로 저장
            
            // words: [] <- 선택한 단어를 저장
            // 오버뷰에서 선택한 현재 세션이 어떤 세션인지 알려주는 @State/Binding 변수가 있어야됨
            let session = Session(id: UUID(), pageId: page.id, words: [])
            
            page.sessions.append(session)
        }
    }
}

//#Preview {
//    WordSelectView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
