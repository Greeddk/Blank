//
//  OCREditView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OCREditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingModal = true
    @Binding var isLinkActive: Bool
    @Binding var generatedImage: UIImage?
    @State var visionStart: Bool = false
    @State var type = ScrribleType.write
    @State private var hasTypeValueChanged = false
    
    /*
     전단계 WordSelectView에서 단어를 선택하면
     해당 단어 목록은 현재 Session 內 Words에 들어가야 할 것 같음
     */
    
    // TODO: - 현재(또는 새로운) 세션 세팅하기
    @State var page: Page

    var body: some View {
        NavigationStack {
            VStack {
                ocrEditImage
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backBtn
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        showModalBtn
                        nextBtn
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .navigationTitle("오타수정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(.systemGray6))
        .onAppear {
            print("OCREditView's basicWords.", page)
        }
    }
    
    private var ocrEditImage: some View {
        // TODO: 텍스트필드를 사진 위에 올려서 확인할 텍스트와 함께 보여주기
        PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]))
    }
    
    private var backBtn: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var showModalBtn: some View {
        Button {
            showingModal = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .sheet(isPresented: $showingModal) {
            ScrribleModalView(selectedType: $type, hasTypeValueChanged: $hasTypeValueChanged)
        }
    }
    
    private var nextBtn: some View {
        NavigationLink(destination: TestPageView(isLinkActive: $isLinkActive, generatedImage: $generatedImage)) {
            Text("시험보기")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 고친 Text값 저장 및 테스트 페이지에 빈칸화 작업
        }
    }
}

//#Preview {
//    OCREditView(viewModel: OverViewModel(),isLinkActive: .constant(true))
//}
