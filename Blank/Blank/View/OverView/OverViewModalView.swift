//
//  OverViewModalView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OverViewModalView: View {
    @ObservedObject var overViewModel: OverViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let item = GridItem(.adaptive(minimum: 120, maximum: 130), spacing: 20)
        let columns = Array(repeating: item, count: 4)
        NavigationView {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVGrid(columns: columns) {
                        ForEach(overViewModel.thumbnails.indices, id: \.self) { index in
                            
                            // TODO: 기기에 따라 크기 조정
                            VStack(spacing: 0) {
                                Image(uiImage: overViewModel.thumbnails[index])
                                    .resizable()
                                    .scaledToFit()
                                    .border(overViewModel.currentPage == index + 1 ? Color.blue : Color.clear, width: 2)
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                                    .onTapGesture {
                                        overViewModel.currentPage = index + 1
                                        setImagesAndData()
                                        dismiss()
                                    }
                                HStack {
                                    Text("\(index+1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                let pageNumberBasedOne = index + 1
                                if overViewModel.lastSessionsOfPages[pageNumberBasedOne] == nil {
                                    Rectangle()
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.5).opacity(0.12))
                                        .cornerRadius(40)
                                        .overlay(
                                            // 해당 페이지 정보 가져오자.
                                            Text("-")
                                                .tint(Color.blue)
                                        )
//                                    Text("시험을 봐주세요")
                                    Text("Please take a test.")
                                        .font(.caption2)
                                    
                                } else if let info = overViewModel.lastSessionCorrectInfo(index: pageNumberBasedOne) {
                                    let lastSessionNumber = overViewModel.loadLastSessionNumber(index: index)
//                                    let info = overViewModel.lastSessionCorrectInfo(index: pageNumberBasedOne)
                                    Rectangle()
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.5).opacity(0.12))
                                        .cornerRadius(40)
                                        .overlay(
//                                            Text("\(lastSessionNumber)회차(\(info.correctRate.percentageTextValue(decimalPlaces: 0)))")
//                                                .tint(Color.blue)
                                            Text("\(lastSessionNumber)st Session(\(info.correctRate.percentageTextValue(decimalPlaces: 0)))")
                                                .tint(Color.blue)
                                                .font(.system(size: 10))
                                        )
//                                    Text("문제:\(info.totalCount)개  정답:\(info.correctCount)개")
                                    Text("Question:\(info.totalCount)\nCorrect Answer:\(info.correctCount)")
                                        .font(.caption2)
                                    
                                }
                            }
                        }
                    }
                    .onAppear(perform:{
                        withAnimation{
                            proxy.scrollTo(overViewModel.currentPage - 1, anchor: .top)
                        }
                        overViewModel.loadModalViewData()
                    })
                }
            }
            .padding()
            .background(Color.customViewBackgroundColor)
            .toolbar {
                Button(action: {
                    dismiss()
                },label: {
                    Text("Done")
                })
                .buttonStyle(.borderedProminent)
            }
            .toolbarBackground(Color.customToolbarBackgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        
    }
}

extension OverViewModalView {
    private func setImagesAndData() {
        // 이미지를 영역에 표시
        overViewModel.generateCurrentImage()
        
        DispatchQueue.global().async {
            // 평균 1.5초 정도 소요
            overViewModel.generateBasicWordsFromCurrentImage {
                DispatchQueue.main.async {
                    overViewModel.loadPage()
                    overViewModel.loadSessionsOfPage()
                }
            }
        }
    }
}

//#Preview {
//    OverViewModalView(viewModel: OverViewModel())
//}

