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
    }
    
    private var testImage: some View{
        // TODO: 시험볼 page에 textfield를 좌표에 만들어 보여주기
        Image("myImage")
            .resizable()
            .scaledToFit()
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
        NavigationLink(destination: ResultPageView(isLinkActive: $isLinkActive)) {
            Text("채점")
                .fontWeight(.bold)
        }
        .onTapGesture {
            // TODO: 채점하기 로직
        }
    }
}

#Preview {
    TestPageView(isLinkActive: .constant(true))
}
