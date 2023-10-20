//
//  ContentView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//

import SwiftUI

struct HomeView: View {
    enum Mode {
        case normal, edit
        
        var toggle: Mode {
            self == .edit ? .normal : .edit
        }
    }
    
    // 현재 일반 모드인지, 아니면 편집(=> 파일삭제) 모드인지
    @State var mode: Mode = .normal
    
    // UI 표시 토글 상태변수
    @State var showFilePicker = false
    @State var showImagePicker = false
    @State var showPDFCreateAlert = false
    @State var showFileDeleteAlert = false
    
    @StateObject var overViewModel: OverViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // 새 PDF 생성 관련
    @State var newPDFFileName = ""
    @State var targetImages: [UIImage]?
    @State var isAllowedCreateNewPDF = false
    
    var body: some View {
        NavigationStack {
            VStack {
                thumbGridView
            }
            .searchable(
                text: $homeViewModel.searchText,
                placement: .navigationBarDrawer,
                prompt: "Search"
            )
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    editBtn
                }
                
                ToolbarItem {
                    if mode == .normal {
                        fileBtnNormalMode
                    } else {
                        fileBtnEditMode
                    }
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
            // Alert 설정: PDF 생성
            .alert("PDF 생성", isPresented: $showPDFCreateAlert) {
                let suggestedFileName = homeViewModel.suggestedFileName
                
                TextField(
                    "",
                    text: $newPDFFileName,
                    prompt: Text(suggestedFileName)
                )
                Button("Cancel") {
                    setAllowCreateNewPDF(false)
                }
                Button("OK") {
                    guard let targetImages else {
                        return
                    }
                    
                    // showPDFCreateAlert 2: OK를 누르면 다음 단계 진행
                    if newPDFFileName.isEmpty {
                        newPDFFileName = suggestedFileName
                    }
                    
                    addImageCombinedPDFToDocument(from: targetImages)
                }
            } message: {
                Text("선택된 이미지들이 병합되어 PDF로 생성됩니다. 파일 이름을 확장자를 제외하고 입력해주세요.")
            }
            // Alert 설정: 선택한 파일 삭제
            .alert("선택한 \(homeViewModel.selectedFileList.count)개의 파일 삭제", isPresented: $showFileDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    
                }
                Button("OK", role: .destructive) {
                    homeViewModel.removeSelectedFiles()
                    // 삭제 완료하면 일반 모드로 이동
                    mode = .normal
                }
            } message: {
                Text("정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    private var thumbGridView: some View {
        let item = GridItem(.adaptive(minimum: 225, maximum: 225), spacing: 30)
        let columns = Array(repeating: item, count: 3)
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(homeViewModel.filteredFileList, id: \.id) { file in
                    NavigationLink(destination: mode == .normal ? OverView(viewModel: overViewModel) : nil) {
                        // TODO: 전체페이지와 시험본 페이지를 각 카드뷰에 넘겨주기
                        ZStack(alignment:.topTrailing) {
                            PDFThumbnailView(file: file)
                            
                            if mode == .edit {
                                Image(homeViewModel.selectedFileList.contains(file) ? "checkedCheckmark" : "emptyCheckmark")
                                    .offset(x: -20, y: 10)
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .disabled(mode == .edit)
                    .onTapGesture {
                        updateSelection(file)
                    }
                }
            }
        }
    }
    
    private var fileBtnNormalMode: some View {
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
    
    private var fileBtnEditMode: some View {
        Button {
            showFileDeleteAlert = true
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
    
    private var editBtn: some View {
        Button {
            mode = mode.toggle
            if mode == .normal {
                homeViewModel.selectedFileList = []
            }
        } label: {
            Text(mode == .normal ? "편집" : "취소")
        }
    }
}

extension HomeView {
    private func addFileToDocument(from url: URL) {
        let copyResult = homeViewModel.copyFileToDocumentBundle(from: url)
        if copyResult {
            homeViewModel.fetchDocumentFileList()
        }
    }
    
    private func addImageCombinedPDFToDocument(from images: [UIImage]) {
        guard images.count > 0 && isAllowedCreateNewPDF else {
            return
        }
        
        do {
            let pdfData = createPDFFromUIImages(from: images)
            try pdfData.write(to: FileManager.documentDirectoryURL!.appendingPathComponent("\(newPDFFileName).pdf"))
            homeViewModel.fetchDocumentFileList()
            
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
    
    private func updateSelection(_ file: File) {
        if !homeViewModel.selectedFileList.contains(file) {
            homeViewModel.selectedFileList.insert(file)
        } else {
            homeViewModel.selectedFileList.remove(file)
        }
    }
}

//#Preview {
//    HomeView()
//        .environmentObject(HomeViewModel())
//}

