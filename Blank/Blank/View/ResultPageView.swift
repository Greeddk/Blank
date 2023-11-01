//
//  ResultPageView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct ResultPageView: View {
    @Binding var isLinkActive: Bool
    @State var isActive = false
    @State var seeCorrect: Bool = true
    @Binding var generatedImage: UIImage?
    @State var visionStart: Bool = false
    
    @StateObject var scoringViewModel: ScoringViewModel
    
    // @StateObject var overViewModel: OverViewModel
    // @Binding var page:Page
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack{
                    resultImage
                    Spacer().frame(height : UIScreen.main.bounds.height * 0.12)
                }
                bottomCorrectInfo
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    homeButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        seeCorrectButton
                        backToOverViewButton
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.blue.opacity(0.2), for: .navigationBar)
            .navigationTitle("결과")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .background(Color(.systemGray6))
        .onAppear {
            scoringViewModel.score()
            
        }
    }
    
    private var bottomCorrectInfo: some View {
        HStack {
            if seeCorrect == true {
                // TODO: 정답률, 문제개수, 정답개수 받아오기
                Spacer().frame(width: 50)
                CorrectInfoView(scoringViewModel: scoringViewModel)
                    .frame(minWidth: 600, maxWidth: 800, minHeight: 50, maxHeight: 70)
                Spacer().frame(width: 50)
            }
            else {
                
            }
        }
    }
    
    private var resultImage: some View {
        // TODO: 각 단어의 정답여부에 따른 색상 마스킹
        // PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]), viewName: "ResultPageView")
        //        PinchZoomView(image: generatedImage, visionStart: $visionStart, basicWords: .constant([]), resultWords: $scoringViewModel.targetWords, viewName: "ResultPageView")
        ImageView(uiImage: generatedImage, visionStart: $visionStart, zoomScale: .constant(1.0), viewName: "ResultPageView", basicWords: .constant([]), targetWords: $scoringViewModel.targetWords)
    }
    
    private var homeButton: some View {
        Button {
            NavigationUtil.popToRootView()
        } label: {
            Image(systemName: "house")
        }
        
    }
    
    private var seeCorrectButton: some View {
        Button {
            seeCorrect.toggle()
        } label: {
            if seeCorrect == true {
                Text("정답률끄기")
            } else {
                Text("정답률보기")
            }
        }
    }
    
    private var backToOverViewButton: some View {
        Button {
            isLinkActive = false
        } label: {
            Text("페이지 선택으로 이동")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    ResultPageView(viewModel: OverViewModel(), isLinkActive: .constant(true))
//}
