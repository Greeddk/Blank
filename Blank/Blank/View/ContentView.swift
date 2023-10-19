//
//  ContentView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct HomeView: View {
    @State var searchQueryString = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                thumbGridView
            }
            .searchable( // TODO: 서치기능
                text: $searchQueryString,
                placement: .navigationBarDrawer,
                prompt: "Search"
            )
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    editBtn
                }
                
                ToolbarItem {
                    fileBtn
                }
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("문서")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var thumbGridView: some View {
        let item = GridItem(.adaptive(minimum: 225, maximum: 225), spacing: 30)
        let columns = Array(repeating: item, count: 3)
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(0..<10) {_ in
                    NavigationLink(destination: OverView()) {
                        // TODO: 전체페이지와 시험본 페이지를 각 카드뷰에 넘겨주기
                        PDFThumbnailView()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private var fileBtn: some View {
        Menu {
            Button {
                // TODO: 파일 보관함 기능
            } label: {
                Text("파일 보관함")
            }
            Button {
                // TODO: 사진 보관함 기능
            } label: {
                Text("사진 보관함")
            }
            
        } label: {
            Text("새 파일")
        }
    }
    
    private var editBtn: some View {
        Button {
            // TODO: 편집 기능
        } label: {
            Text("편집")
        }
    }
}

#Preview {
    HomeView()
}
