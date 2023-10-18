//
//  ContentView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    // UI 표시 토글 상태변수
    @State var showFilePicker = false
    @State var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                thumbGridView
            }
            .searchable( // TODO: 서치기능
                text: $viewModel.searchText,
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
            // 시트뷰 설정
            .sheet(isPresented: $showFilePicker) {
                DocumentPickerReperesentedView { url in
                    addFileToDocument(from: url)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPickerRepresentedView { images in
                    print(images)
                }
            }
        }
    }
    
    private var thumbGridView: some View {
        let item = GridItem(.adaptive(minimum: 225, maximum: 225), spacing: 30)
        let columns = Array(repeating: item, count: 3)
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.filteredFileList, id: \.id) { file in
                    NavigationLink(destination: OverView()) {
                        PDFThumbnailView(file: file)
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private var fileBtn: some View {
        Menu {
            Button {
                showFilePicker = true
            } label: {
                Text("파일 보관함")
            }
            Button {
                showImagePicker = true
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

extension HomeView {
    private func addFileToDocument(from url: URL) {
        let copyResult = viewModel.copyFileToDocumentBundle(from: url)
        if copyResult {
            viewModel.fetchDocumentFileList()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}
