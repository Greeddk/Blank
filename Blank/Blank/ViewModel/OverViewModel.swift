//
//  PDFKitView.swift
//  Blank
//
//  Created by Greed on 10/18/23.
//

import Foundation
import PDFKit
import Vision

class OverViewModel: ObservableObject {
    @Published var currentPage: Int = 1
    @Published var currentImage: UIImage?
    @Published var thumbnails = [UIImage]()
    
    //프로그레스뷰를 위한 변수
    @Published var isLoading = true
    @Published var currentProgress: Double = 0.0
    
    /// OverView 내에 있는 PinchZoom-ImageView에서 받은 빨간 박스(Basic Words)들을 저장합니다.
    var basicWords: [BasicWord] = []
    @Published var selectedPage: Page?
    @Published var sessions: [Session] = []
    @Published var statsOfSessions: [UUID: SessionStatistics] = [:]
    @Published var currentSession: Session?
    @Published var wordsOfSession: [UUID: [Word]] = [:]
    @Published var totalStats: [CGRect: WordStatistics] = [:]
    @Published var isTotalStatsViewMode = false
    @Published var lastSession: Session?
    @Published var lastSessionsOfPages: [Int: Session?] = [:]
    
    let currentFile: File
    lazy var pdfDocument: PDFDocument = PDFDocument(url: currentFile.fileURL)!
    
    
    init(currentFile: File) {
        self.currentFile = currentFile
    }
    
    var totalSessionCount: Int {
        sessions.count
    }
    
    func createNewPageAndSession() -> Page {
        let page = Page(id: UUID(),
                        fileId: currentFile.id,
                        currentPageNumber: currentPage
        )

        return page
    }
    
    func loadLastSessionNumber(index: Int) -> Int {
        do {
            if let loadedFile = try CDService.shared.readFile(from: currentFile.fileURL.lastPathComponent) {
                let pages = try CDService.shared.readAllPages(fileId: loadedFile.id)
                let page = pages[index]
                let lastSessionNumber = try CDService.shared.loadAllSessions(of: page).count
                return lastSessionNumber
            }
        } catch {
            print(#function, error)
        }
        return 0
    }
    
    // 오버뷰모달뷰에서 각 페이지의 마지막 세션의 정보를 불러오기 위한 작업
    func loadModalViewData() {
        do {
            if let loadedFile = try CDService.shared.readFile(from: currentFile.fileURL.lastPathComponent) {
                let pages = try CDService.shared.readAllPages(fileId: loadedFile.id)
                for page in pages {
                    if let lastSession = try CDService.shared.loadAllSessions(of: page).last {
                        lastSessionsOfPages[page.currentPageNumber] = lastSession
                    }
                }
            }
        } catch {
            print(#function, error)
        }
    }
    
    func lastSessionCorrectInfo(index: Int) -> SessionStatistics? {
        let session = self.lastSessionsOfPages[index]
        
        if let shelledSession = session,
            let realSession = shelledSession,
           let words = try? CDService.shared.loadAllWords(of: realSession) {
            let correctCount = words.reduce(0) {
                $0 + ($1.isCorrect ? 1 : 0)
            }
            
            return SessionStatistics(correctCount: correctCount, totalCount: words.count)
        }
        
        return nil
    }
    
    /// CoreData: Page가 CoreData에 있으면 Load, 없으면 생성 후 Save
    func loadPage() {
        do {
            // TODO: HomeView에서 파일을 로딩해서 넘어갈 때 이것을 하게 함
            if let file = try CDService.shared.readFile(from: currentFile.fileURL.lastPathComponent) {
                if let page = try CDService.shared.readPage(fileId: file.id, pageNumber: currentPage) {
                    print("[DEBUG] loadPage 1: file % page Loaded")
                    selectedPage = page
                    return
                }
                
                // file은 있으면
                let page = Page(id: UUID(), fileId: file.id, currentPageNumber: currentPage)
                try CDService.shared.appendPage(to: file, page: page)
                print("[DEBUG] loadPage 2: file Loaded, page created")
                selectedPage = page
                return
            }
            
            // file도 없으면
            let file: File = .init(id: UUID(), fileURL: currentFile.fileURL, fileName: currentFile.fileName, totalPageCount: currentFile.totalPageCount)
            let page = Page(id: UUID(), fileId: file.id, currentPageNumber: currentPage)
            
            try CDService.shared.createFile(from: file)
            try CDService.shared.appendPage(to: file, page: page)
            print("[DEBUG] loadPage 3: file, page created")
            
            selectedPage = page
        } catch {
            print(#function, "catched error: ", error)
        }
    }
    
    func loadSessionsOfPage() {
        // 세션 로딩
        do {
            guard let selectedPage else {
                print("[DEBUG] selectedPage is nil")
                return
            }
            
            sessions = try CDService.shared.loadAllSessions(of: selectedPage)
            print("[DEBUG] Loaded Sessions:", sessions.count)
            
            // 페이지 바뀔때는 wordsOfSession, statsOfSessions를 초기화
            wordsOfSession = .init()
            statsOfSessions = .init()
            totalStats = .init()
            
            sessions.forEach {
                if let words = try? CDService.shared.loadAllWords(of: $0) {
                    wordsOfSession[$0.id] = words
                    
                    statsOfSessions[$0.id] = .init(
                        correctCount: words.reduce(0, {
                            return $0 + ($1.isCorrect ? 1 : 0)
                        }),
                        totalCount: words.count
                    )
                }
            }
            
            // 마지막으로 시험 본 세션을 불러서 저장하는 코드
            if sessions.count >= 1 {
                lastSession = sessions.last
            }
        } catch {
            
        }
    }
    
    func selectCurrentSessionAndWords(index: Int) -> [Word] {
        guard index < sessions.count else {
            return []
        }
        
        currentSession = sessions[index]
        
        guard let currentSession else {
            return []
        }
        
        return wordsOfSession[currentSession.id, default: []]
    }
    
    func generateTotalStatistics() {
        let allWords = wordsOfSession.values.flatMap { $0 }
        
        allWords.forEach { word in
            totalStats[word.rect, default: .init(id: word.rect, correctSessionCount: 0, totalSessionCount: 0)].correctSessionCount += (word.isCorrect ? 1 : 0)
            totalStats[word.rect, default: .init(id: word.rect, correctSessionCount: 0, totalSessionCount: 0)].totalSessionCount += 1
        }
        
        print(totalStats)
    }
    
    /// PDF의 원하는 페이지를 로드해주는 메소드
    func updateCurrentPage(from input: String) {
        let originalPage = self.currentPage
        if let pageNumber = Int(input),
           pageNumber >= 1,
           pageNumber <= self.pdfTotalPage() {
            self.currentPage = pageNumber
        } else {
            self.currentPage = originalPage
        }
    }
    
    /// PDF 전체 페이지 수를 반환하는 메소드
    func pdfTotalPage() -> Int {
        //         guard let pdfDocument = pdfDocument else { return 0 }
        return pdfDocument.pageCount
    }
    
    /// PDF의 현재 페이지를 이미지로 반환하는 메소드
    func generateImage() -> UIImage? {
        
        guard let page = pdfDocument.page(at: currentPage - 1) else {
            return nil
        }
        
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let image = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: pageRect.size))
            
            ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        
        
        return image
    }
    
    // PDF의 모든 페이지를 썸네일 이미지로 배열에 저장하는 메소드, 진행률도 표시
    func loadThumbnails() {
        isLoading = true
        currentProgress = 0.0
        
        //        guard let pdfDocument = pdfDocument else {
        //            return
        //        }
        
        if thumbnails.count != pdfDocument.pageCount {
            thumbnails.removeAll()
            
            Task.init { // Create a new Task for loading PDF
                for i in 0..<pdfDocument.pageCount {
                    guard let page = pdfDocument.page(at: i) else {
                        continue
                    }
                    
                    let image = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)
                    
                    await MainActor.run {
                        self.thumbnails.append(image)
                        self.currentProgress = Double(i + 1) / Double(pdfDocument.pageCount)
                        
                        if currentProgress == 1.0 {
                            self.isLoading = false // Loading complete
                        }
                    }
                }
            }
        } else {
            isLoading = false // Loading complete
        }
    }
    
    // completion은 recognizeText함수자체가 이미지에서 텍스트를 인식하는 비동기 작업을 수행하니까
    // 함수가 종료되었을 때가 아닌 작업이 완료되었을때 completion클로저를 호출해야됨
    func recognizeTextTwo(from image: UIImage, completion: @escaping ([(String, CGRect)]) -> Void) {
        // 이미지 CGImage로 받음
        guard let cgImage = image.cgImage else { return }
        // VNImageRequestHandler옵션에 URL로 경로 할 수도 있고 화면회전에 대한 옵션도 가능
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // 텍스트 인식 작업이 완료되었을때 실행할 클로저 정의
        let request = VNRecognizeTextRequest { (request, error) in
            var recognizedTexts: [(String, CGRect)] = [] // 단어랑 좌표값담을 빈 배열 튜플 생성
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                for observation in results {
                    if let topCandidate = observation.topCandidates(1).first {
                        let words = topCandidate.string.split(separator: " ")
                        
                        for word in words {
                            if let range = topCandidate.string.range(of: String(word)) {
                                if let box = try? topCandidate.boundingBox(for: range) {
                                    let boundingBox = VNImageRectForNormalizedRect(box.boundingBox, Int(image.size.width), Int(image.size.height))
                                    recognizedTexts.append((String(word), boundingBox))
                                }
                            }
                        }
                    }
                }
            }
            completion(recognizedTexts)
        }
        
        request.recognitionLanguages = ["ko-KR"]
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.01
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing text recognition request: \(error)")
        }
    }
    
    /// currentImage로부터 basicWords를 생성
    func generateBasicWordsFromCurrentImage(completionHandler: (() -> Void)? = nil) {
        guard let currentImage else {
            return
        }
        
        recognizeTextTwo(from: currentImage) { recognizedTexts in
            self.basicWords = recognizedTexts.map {
                .init(id: UUID(), wordValue: $0.0, rect: $0.1, isSelectedWord: false)
            }
            
            completionHandler?()
        }
    }
    
    func generateCurrentImage() {
        guard let page = pdfDocument.page(at: currentPage - 1) else {
            return
        }
        
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        currentImage = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: pageRect.size))
            
            ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
}
