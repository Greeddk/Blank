//
//  TestView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct TestPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingModal = false
    @Binding var isLinkActive: Bool
    @Binding var generatedImage: UIImage?
    @State var visionStart: Bool = false
    @State var type = ScrribleType.write
    @State private var hasTypeValueChanged = false

    var body: some View {
        NavigationStack {
            VStack {
                testImage
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
            .navigationTitle("시험")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(.systemGray6))
    }
    
    private var testImage: some View{
        // TODO: 시험볼 page에 textfield를 좌표에 만들어 보여주기
        TestPagePinchZoomView(image: generatedImage, basicWords: .constant([]))
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
        NavigationLink(destination: ResultPageView(isLinkActive: $isLinkActive, generatedImage: $generatedImage)) {
            Text("채점")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 채점하기 로직
        }
    }
}

//#Preview {
//    TestPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
