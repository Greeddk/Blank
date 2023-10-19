//
//  OCREditView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OCREditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: OverViewModel
    @State private var showingModal = true
    @Binding var isLinkActive: Bool
    
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
    }
    
    private var ocrEditImage: some View {
        // TODO: 텍스트필드를 사진 위에 올려서 확인할 텍스트와 함께 보여주기
        ScrollView {
            CurrentPageView(image: viewModel.generateImage())
        }
        .frame(width: UIScreen.main.bounds.width)
        .background(Color(.systemGray6))
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
            ScribbleModalView()
        }
    }
    
    private var nextBtn: some View {
        NavigationLink(destination: TestPageView(viewModel: viewModel, isLinkActive: $isLinkActive)) {
            Text("시험보기")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 고친 Text값 저장 및 테스트 페이지에 빈칸화 작업
        }
    }
}

#Preview {
    OCREditView(viewModel: OverViewModel(),isLinkActive: .constant(true))
}
