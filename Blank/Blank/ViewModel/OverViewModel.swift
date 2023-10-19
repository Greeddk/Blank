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
    @Published var isLoading = true
    @Published var currentProgress: Double = 0.0
    
    let documentURL = Bundle.main.url(forResource: "samplepdf", withExtension: "pdf")
    var pdfDocument: PDFDocument?
    
    init() {
        if let documentURL = documentURL {
            pdfDocument = PDFDocument(url: documentURL)
        }
    }
    
    // PDF 전체 페이지 수를 반환하는 메소드
    func pdfTotalPage() -> Int {
        guard let pdfDocument = pdfDocument else { return 0 }
        
        return pdfDocument.pageCount
    }
    
    // PDF의 현재 페이지를 이미지로 반환하는 메소드
    func generateImage() -> UIImage? {
        guard let pdfDocument = pdfDocument, currentPage > 0, currentPage <= pdfDocument.pageCount else {
            return nil
        }
        
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

        guard let pdfDocument = pdfDocument else {
            return
        }

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
