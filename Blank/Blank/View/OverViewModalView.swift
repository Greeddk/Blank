//
//  OverViewModalView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct OverViewModalView: View {
    @StateObject var viewModel: OverViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let item = GridItem(.adaptive(minimum: 120, maximum: 130), spacing: 20)
        let columns = Array(repeating: item, count: 4)
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                },label: {
                    Text("Done")
                        .padding(20)
                })
            }
            Spacer().frame(height: 0)
            Divider()
            Spacer().frame(height: 0)
            NavigationView {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.thumbnails.indices, id: \.self) {index in
                                // TODO: 기기에 따라 크기 조정
                                VStack {
                                    Image(uiImage: viewModel.thumbnails[index])
                                        .resizable()
                                        .scaledToFit()
                                        .border(viewModel.currentPage == index + 1 ? Color.blue : Color.clear, width: 2)
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                                        .onTapGesture {
                                            DispatchQueue.main.async {
                                                viewModel.currentPage = index + 1
                                                dismiss()
                                            }
                                        }
                                    HStack {
                                        Text("\(index+1)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    Rectangle()
                                        .frame(width: 80, height: 20)
                                        .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.5).opacity(0.12))
                                        .cornerRadius(40)
                                        .overlay(
                                            Text("n회차")
                                                .tint(Color.blue)
                                        )
                                    Text("정답률 : 25%")
                                    Text("문제 : 127개")
                                    Text("정답 : 32개")
                                }
                                .foregroundColor(.black)
                            }
//                            .onChange(of: viewModel.currentPage) { value in
//                                withAnimation {
//                                    proxy.scrollTo(value-1, anchor: .top)
//                                }
//                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray5))
            }
        }
    }
}

#Preview {
    OverViewModalView(viewModel: OverViewModel())
}
