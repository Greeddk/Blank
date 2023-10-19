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
    @State var showPDFCreateAlert = false
    @State var isClicked = false
    @StateObject var overViewModel: OverViewModel
    
    // 새 PDF 생성 관련
    @State var newPDFFileName = ""
    @State var targetImages: [UIImage]?
    @State var isAllowedCreateNewPDF = false
    
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
                // showPDFCreateAlert 1: 이미지 선택 창을 띄우고 끝나면 경고창 띄움
                // TODO: - 인디케이터 로딩 시작
                PhotoPickerRepresentedView { images in
                    // TODO: - 인디케이터 로딩 끝
                    targetImages = images
                    setAllowCreateNewPDF(true)
                    showPDFCreateAlert = true
                }
            }
            // Alert 설정
            .alert("PDF 생성", isPresented: $showPDFCreateAlert) {
                TextField("", text: $newPDFFileName)
                Button("Cancel") {
                    setAllowCreateNewPDF(false)
                }
                Button("OK") {
                    guard let targetImages else {
                        return
                    }
                    
                    // showPDFCreateAlert 2: OK를 누르면 다음 단계 진행
                    addImageCombinedPDFToDocument(from: targetImages)
                }
                .disabled(!newPDFFileName.isEmpty)
                
                // .disabled(newPDFFileName.isEmpty)
            } message: {
                Text("선택된 이미지들이 병합되어 PDF로 생성됩니다. 파일 이름을 확장자를 제외하고 입력해주세요.")
            }
            
        }
    }
    
    private var thumbGridView: some View {
        let item = GridItem(.adaptive(minimum: 225, maximum: 225), spacing: 30)
        let columns = Array(repeating: item, count: 3)
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.filteredFileList, id: \.id) { file in
                    NavigationLink(destination: OverView(viewModel: overViewModel)) {
                        // TODO: 전체페이지와 시험본 페이지를 각 카드뷰에 넘겨주기
                        ZStack(alignment:.topTrailing) {
                            PDFThumbnailView(file: file)
                            if isClicked {
                                let imageName = isClicked ? "checkedCheckmark" : "emptyCheckmark"
                                Image(imageName)
                                    .offset(x:-20, y:10)
                            }
                        }
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
            showPDFCreateAlert = true
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
    
    private func addImageCombinedPDFToDocument(from images: [UIImage]) {
        guard images.count > 0 && !newPDFFileName.isEmpty && isAllowedCreateNewPDF else {
            return
        }
        
        do {
            let pdfData = createPDFFromUIImages(from: images)
            try pdfData.write(to: FileManager.documentDirectoryURL!.appendingPathComponent("\(newPDFFileName).pdf"))
            viewModel.fetchDocumentFileList()
            
            setAllowCreateNewPDF(false)
        } catch {
            print("write pdf error:", error)
            setAllowCreateNewPDF(false)
        }
    }
    
    private func setAllowCreateNewPDF(_ isAllow: Bool) {
        isAllowedCreateNewPDF = isAllow
        newPDFFileName = ""
    }
}

//#Preview {
//    HomeView()
//        .environmentObject(HomeViewModel())
//}

