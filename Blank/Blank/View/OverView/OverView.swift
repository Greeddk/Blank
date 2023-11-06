//
//  OverView.swift
//  MacroView
//
//  Created by Greed on 10/14/23.
//


import SwiftUI
import Vision

struct OverView: View {
    @Environment(\.dismiss) private var dismiss
    
    //뷰모델
    @StateObject var overViewModel: OverViewModel
    
    @State var goToNextPage = false
    
    //n회차 alert flag
    @State var showingAlert = false
    //n회차 일때 한번에 테스트 페이지로 가기 위한 bool값
    @State var goToTestPage = false
    
    //제목 버튼 팝오버 버튼
    @State private var showPopover = false
    @State private var showModal = false
    
    @State var visionStart = false
    
    @State var seeResult = false
    @State private var selectedSessionIndex: Int?
    
    // @State private var generatedImage: UIImage?
    @State private var currentPageText: String = ""
    @State var titleName = "파일이름"
    
    @State private var disableReadToTestButton = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if overViewModel.isLoading && overViewModel.currentProgress < 1.0 {
                    progressStatus
                    
                } else if !overViewModel.thumbnails.isEmpty {
                    ZoomableContainer {
                        OverViewImageView(visionStart: $visionStart,
                                          overViewModel: overViewModel,
                                          zoomScale: .constant(1.0))
                    }
                    bottomScrollView
                }
            }
            .background(Color(.systemGray4))
            .onAppear {
                overViewModel.loadThumbnails()
                setImagesAndData()
                goToTestPage = false
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leftButtons
                }
                
                ToolbarItem(placement: .principal) {
                    centerButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    goToNextPageButton
                }
            }
            .toolbarBackground(.blue.opacity(0.2), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .navigationTitle(titleName)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .navigationDestination(isPresented: $goToNextPage) {
            if !goToTestPage {
                // TODO: - 이미 생성한 페이지라면 다시 생성되지 않게 해야됨, CoreData에서 페이지 있는지 검사
                if let page = overViewModel.selectedPage {
                    let wordSelectViewModel = WordSelectViewModel(page: page, basicWords: overViewModel.basicWords, currentImage: overViewModel.currentImage)
                    WordSelectView( wordSelectViewModel: wordSelectViewModel)
                } else {
                    Text("Error")
                }
            // 바로 시험보기 버튼을 눌렀을 시
            } else if let page = overViewModel.selectedPage, let lastSession = overViewModel.lastSession, let words = overViewModel.wordsOfSession[lastSession.id] {
                    
                    let wordSelectViewModel = WordSelectViewModel(page: page, basicWords: overViewModel.basicWords)
                    
                    TestPageView(
                        scoringViewModel: .init(
                            page: wordSelectViewModel.page,
                            session: wordSelectViewModel.session,
                            currentWritingWords: words.map { .init(id: $0.id, sessionId: $0.sessionId, wordValue: "", rect: $0.rect, isCorrect: $0.isCorrect) },
                            targetWords: words, 
                            currentImage: overViewModel.currentImage
                        )
                    )
                }
        }
        .alert("시험지 선택" ,isPresented: $showingAlert) {
            Button("마지막 회차 다시 보기") {
                goToTestPage = true
                goToNextPage = true
            }
            Button("새빈칸 시험지 만들기") {
                goToNextPage = true
            }
            Button("취소", role: .cancel) {

            }
        } message: {
            Text("""
                 기존에 시험을 본 내용이 있습니다.
                 마지막 회차 시험을 바로 보시겠습니까?
                 새로 빈칸 시험지를 만드시겠습니까?
                 """)
        }
    }
    
    private var progressStatus: some View {
        VStack(spacing: 20) {
            ProgressView(value: overViewModel.currentProgress)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("파일을 로딩 중 입니다.")
            
            Text("\(Int(overViewModel.currentProgress * 100))%") // 퍼센트로 변환하여 표시
        }
        .background(.white)
    }
    
    private var bottomScrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            Spacer().frame(height: 10)
            ScrollViewReader { proxy in
                LazyHStack(spacing: 10) {
                    Spacer()
                    ForEach(overViewModel.thumbnails.indices, id: \.self) { index in
                        VStack {
                            Image(uiImage: overViewModel.thumbnails[index])
                                .resizable()
                                .aspectRatio(contentMode:.fit)
                                .border(overViewModel.currentPage == index + 1 ? Color.blue : Color.clear, width: 1)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
                            Spacer().frame(height: 0)
                            Text("\(index+1)")
                                .font(.caption)
                        }
                        .onTapGesture {
                            overViewModel.currentPage = index + 1
                            setImagesAndData()
                        }
                    }
                    Spacer()
                }
                .onChange(of: overViewModel.currentPage, perform: { value in
                    withAnimation {
                        proxy.scrollTo(value - 1, anchor: .center)
                    }
                })
                .onAppear() {
                    DispatchQueue.main.async {
                        proxy.scrollTo(overViewModel.currentPage - 1, anchor: .center)
                    }
                }
            }
        }
        .background(Color.white)
        .frame(height : UIScreen.main.bounds.height * 0.11)
    }
    
    private var centerButton: some View {
        Button {
            showPopover = true
        } label: {
            HStack {
                Text("\(overViewModel.currentFile.fileName)")
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.black)
            .fontWeight(.bold)
        }
        .popover(isPresented: $showPopover) {
            popoverContent
        }
    }
    
    private var popoverContent: some View {
        VStack {
            Form {
                Text("\(overViewModel.currentFile.fileName)")
                HStack {
                    Text("페이지 : ")
                    Spacer()
                    TextField("", text: $currentPageText, onCommit:{
                        overViewModel.updateCurrentPage(from: currentPageText)
                    })
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    Text(" / \(overViewModel.pdfTotalPage())")
                    Button {
                        overViewModel.updateCurrentPage(from: currentPageText)
                    } label: {
                        Text("이동")
                    }
                }
            }
        }
        .frame(width: 300, height: 150)
        .onAppear() {
            currentPageText = "\(overViewModel.currentPage)"
        }
    }
    
    private var leftButtons: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            
            Button {
                showModal = true
            } label: {
                Image(systemName: "square.grid.2x2.fill")
            }
            .sheet(isPresented: $showModal) {
                OverViewModalView(overViewModel: overViewModel)
            }
            
            Menu {
                // TODO: 회차가 끝날때마다 해당 회차 결과 생성 및 시험 본 부분 색상 처리(버튼으로)
                Button("전체통계") {
                    overViewModel.generateTotalStatistics()
                    overViewModel.isTotalStatsViewMode = true
                    seeResult = false
                    selectedSessionIndex = nil
                    
                }
                .disabled(overViewModel.sessions.isEmpty)
                
                ForEach(overViewModel.sessions.indices, id: \.self) { index in
                    let percentageValue = overViewModel.statsOfSessions[overViewModel.sessions[index].id]?.correctRate.percentageTextValue(decimalPlaces: 0) ?? "0%"
                    Button("\(index + 1)회차 (\(percentageValue))") {
                        overViewModel.isTotalStatsViewMode = false
                        _ = overViewModel.selectCurrentSessionAndWords(index: index)
                        selectedSessionIndex = index
                        seeResult = true
                    }
                }
            } label: {
                if !seeResult && !overViewModel.isTotalStatsViewMode {
                    Label("결과보기", systemImage: "chevron.down")
                        .labelStyle(.titleAndIcon)
                } else if seeResult {
                    Label("\(selectedSessionIndex! + 1)회차", systemImage: "chevron.down")
                        .labelStyle(.titleAndIcon)
                } else {
                    Label("전체통계", systemImage: "chevron.down")
                        .labelStyle(.titleAndIcon)
                }
            }
            
            Button {
                // TODO: 원본 페이지 상태로 변경
                seeResult = false
                overViewModel.isTotalStatsViewMode = false
            } label: {
                Text("원본")
            }
        }
    }
    
    private var goToNextPageButton: some View {
        
        Button {
            // TODO: 해당 페이지 이미지 파일로 넘겨주기, layer 분리, 이미지 받아서 텍스트로 변환, 2회차 이상일때 내용수정 Alert 만들기
            // TODO: 2회차 이상일때 alert 띄울 로직
            visionStart = true
            if overViewModel.sessions.count >= 1 {
                showingAlert = true
            } else {
                goToNextPage = true
            }
        } label: {
            Text("시험준비")
                .fontWeight(.bold)
        }
        .buttonStyle(.borderedProminent)
        // 단어 영역 생성이 끝날때까지 비활성화
        .disabled(disableReadToTestButton)
    }
    
}

extension OverView {
    private func setImagesAndData() {
        // 이미지를 영역에 표시
        overViewModel.generateCurrentImage()
        
        DispatchQueue.global().async {
            // 평균 1.5초 정도 소요
            overViewModel.generateBasicWordsFromCurrentImage {
                DispatchQueue.main.async {
                    overViewModel.loadPage()
                    overViewModel.loadSessionsOfPage()
                    disableReadToTestButton = false
                }
            }
        }
    }
}

//#Preview {
//    OverView(overViewModel: OverViewModel())
//}

