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
    }
    
    private var wordSelectImage: some View {
        // TODO: 단어 선택시 해당 단어 위에 마스킹 생성 기능, 다시 터치시 해제, 비전 스타트가 여기에 필요한지..?
        PinchZoomView(image: generatedImage, visionStart: $visionStart)
    }
    
    private var backBtn: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var nextBtn: some View {
        NavigationLink(destination: OCREditView(isLinkActive: $isLinkActive, generatedImage: $generatedImage)) {
            Text("다음")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 선택된 단어를 배열로 저장
        }
    }
}

//#Preview {
//    WordSelectView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
