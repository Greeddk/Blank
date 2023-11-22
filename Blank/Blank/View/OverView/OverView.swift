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
                    // progressStatus
                    ProgressStatusView(currentProgress: $overViewModel.currentProgress)
                } else if !overViewModel.thumbnails.isEmpty {
                    ZStack(alignment:.topTrailing) {
                        OverViewImageView(visionStart: $visionStart,
                                          overViewModel: overViewModel)
                        StatIndexView
                    }
                    bottomScrollView
                }
            }
            .background(Color.customBackgroundColor)
            .onAppear {
                overViewModel.loadThumbnails()
                setImagesAndData()
                goToTestPage = false
            }
            .sheet(isPresented: $showModal) {
                OverViewModalView(overViewModel: overViewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        backButton
                        modalButton
                        statsButton
                        showOriginalImageButton
                    }
                    
                }
                
                ToolbarItem(placement: .principal) {
                    centerButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    goToNextPageButton
                }
            }
            .toolbarBackground(Color.customNavigationColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .ignoresSafeArea(.keyboard)
            
        }
        .navigationDestination(isPresented: $goToNextPage) {
            if !goToTestPage {
                // TODO: - 이미 생성한 페이지라면 다시 생성되지 않게 해야됨, CoreData에서 페이지 있는지 검사
                if let page = overViewModel.selectedPage {
                    let wordSelectViewModel = WordSelectViewModel(page: page, basicWords: overViewModel.basicWords, currentImage: overViewModel.currentImage)
                    WordSelectView( sessionNum: overViewModel.sessions.count + 1, wordSelectViewModel: wordSelectViewModel)
                } else {
                    Text("Error")
                }
                // 바로 시험보기 버튼을 눌렀을 시
            } else if let page = overViewModel.selectedPage, let lastSession = overViewModel.lastSession, let words = overViewModel.wordsOfSession[lastSession.id] {
                
                let wordSelectViewModel = WordSelectViewModel(page: page, basicWords: overViewModel.basicWords)
                
                TestPageView(
                    sessionNum: overViewModel.sessions.count + 1,
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
        .alert("어떤 시험지를 고르시겠어요?" ,isPresented: $showingAlert) {
            Button("새로 만들기") {
                goToNextPage = true
            }
            Button("시험 보기") {
                goToTestPage = true
                goToNextPage = true
            }
            Button("취소", role: .cancel) {
                
            }
        } message: {
            Text("""
                 새로운 빈칸을 만들거나,
                 지난 회차 시험을 볼 수 있습니다.
                 """)
        }
    }
    
    private var StatIndexView: some View {
        HStack {
            if overViewModel.isTotalStatsViewMode {
                Spacer()
                StatModeIndexView()
                    .cornerRadius(20)
                    .frame(minWidth: 150, maxWidth: 200, minHeight: 100, maxHeight: 150)
                    
            }
        }
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
                            clearCorrectWordArea()
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
                        setImagesAndData()
                    })
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(width: 50)
                    Text(" / \(overViewModel.pdfTotalPage())")
                    Button {
                        overViewModel.updateCurrentPage(from: currentPageText)
                        setImagesAndData()
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
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.gray.opacity(0.2))
                .frame(width: 35, height: 35)
                .overlay {
                    Image(systemName: "chevron.left")
                }
        }
        
    }
    
    private var modalButton: some View {
        Button {
            showModal = true
        } label: {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.gray.opacity(0.2))
                .frame(width: 35, height: 35)
                .overlay {
                    Image(systemName: "square.grid.2x2.fill")
                }
        }
    }
    
    private var statsButton: some View {
        VStack {
            if overViewModel.sessions.isEmpty {
                
            } else {
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
                            setCorrectWordArea(index)
                        }
                    }
                } label: {
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .fill(.gray.opacity(0.2))
                        .frame(width: 100, height: 35)
                        .overlay {
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
                }
            }
        }
        
    }
    
    private var showOriginalImageButton: some View {
        VStack {
            if seeResult || overViewModel.isTotalStatsViewMode {
                Button {
                    seeResult = false
                    overViewModel.isTotalStatsViewMode = false
                    clearCorrectWordArea()
                } label: {
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .fill(.gray.opacity(0.2))
                        .frame(width: 40, height: 35)
                        .overlay {
                            Text("원본")
                        }
                }
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
            Text("빈칸 만들기")
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
    
    /// 회차가 변경되면 그 회차에 맞춰 단어 사각형 새로 그리기
    private func setCorrectWordArea(_ index: Int) {
        overViewModel.isTotalStatsViewMode = false
        _ = overViewModel.selectCurrentSessionAndWords(index: index)
        selectedSessionIndex = index
        seeResult = true
    }
    
    private func clearCorrectWordArea() {
        overViewModel.isTotalStatsViewMode = false
        overViewModel.currentSession = nil
        selectedSessionIndex = nil
        seeResult = false
    }
    
}

//#Preview {
//    OverView(overViewModel: OverViewModel())
//}

