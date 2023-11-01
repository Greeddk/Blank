//
//  PDFKitView.swift
//  Blank
//
//  Created by Greed on 10/18/23.
//

import PDFKit
import Foundation

class OverViewModel: ObservableObject {
    @Published var currentPage: Int = 1
    @Published var thumbnails = [UIImage]()
    
    //프로그레스뷰를 위한 변수
    @Published var isLoading = true
    @Published var currentProgress: Double = 0.0
    
    /// OverView 내에 있는 PinchZoom-ImageView에서 받은 빨간 박스(Basic Words)들을 저장합니다.
    @Published var basicWords: [BasicWord] = []
    @Published var selectedPage: Page?
    @Published var sessions: [Session] = []
    @Published var statsOfSessions: [UUID: SessionStatistics] = [:]
    
    
    let currentFile: File
    lazy var pdfDocument: PDFDocument = PDFDocument(url: currentFile.fileURL)!
    
    
    init(currentFile: File) {
        self.currentFile = currentFile
    }
    
    var totalSessionCount: Int {
        sessions.count
    }
    
    func createNewPageAndSession() -> Page {
        var page = Page(id: UUID(),
                        fileId: currentFile.id,
                        currentPageNumber: currentPage
        )
        // let newSession = Session(id: UUID(), pageId: page.id, words: [])
        // page.sessions.append(newSession)
        
        return page
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
            sessions.forEach {
                if let words = try? CDService.shared.loadAllWords(of: $0) {
                    
                    statsOfSessions[$0.id] = .init(
                        correctCount: words.reduce(0, {
                            return $0 + ($1.isCorrect ? 1 : 0)
                        }),
                        totalCount: words.count
                    )
                }
            }
        } catch {
            
        }
    }
    
    // PDF의 원하는 페이지를 로드해주는 메소드
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
    
    // PDF 전체 페이지 수를 반환하는 메소드
    func pdfTotalPage() -> Int {
        //         guard let pdfDocument = pdfDocument else { return 0 }
        return pdfDocument.pageCount
    }
    
    // PDF의 현재 페이지를 이미지로 반환하는 메소드
    func generateImage() -> UIImage? {
        //        guard let pdfDocument = pdfDocument, currentPage > 0, currentPage <= pdfDocument.pageCount else {
        //            return nil
        //        }
        
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
    
    // PDF의 모든 페이지를 썸네일 이미지로 배열에 저장하는 메소드
    //         func loadPDF() async {
    //            guard let pdfDocument = pdfDocument else {
    //                return
    //            }
    //
    //            thumbnails.removeAll() // 이미지 배열 초기화
    //
    //            DispatchQueue.global().async {
    //                for i in 0..<pdfDocument.pageCount {
    //                    guard let page = pdfDocument.page(at: i) else {
    //                        continue
    //                    }
    //
    //                    let image = page.thumbnail(of: CGSize(width: 500, height: 700), for: .mediaBox)
    //                    DispatchQueue.main.async {
    //                        self.thumbnails.append(image)
    //                    }
    //                }
    //            }
    //        }
    
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
    
    
    
}
