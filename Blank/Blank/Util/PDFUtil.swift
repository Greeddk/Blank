//
//  PDFUtil.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/18.
//

import UIKit
import PDFKit

func generateThumbnail(of thumbnailSize: CGSize, for url: URL, atPage pageIndex: Int) -> UIImage? {
    PDFDocument(url: url)?.page(at: pageIndex)?.thumbnail(of: thumbnailSize, for: .trimBox)
}

func pageCount(of url: URL) -> Int? {
    PDFDocument(url: url)?.pageCount
}

/// 이미지 여러장을 순서대로 조합해 PDF 데이터 생성
/// https://stackoverflow.com/questions/10486888/convert-multiple-images-as-pdf-with-multiple-page
/// - Parameters:
///   - images: 이미지 배열 (순서대로)
func createPDFFromUIImages(from images: [UIImage]) -> NSMutableData {
    let pdfData = NSMutableData()
    let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
    
    let maxWidth = images.max { $0.size.width > $1.size.width }
    let maxHeight = images.max { $0.size.height > $1.size.height }
    
    var mediaBox = CGRect.init(x: 0, y: 0, width: 3000, height: 3000)
    let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
    
    for image in images {
        var mediaBox = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        pdfContext.beginPage(mediaBox: &mediaBox)
        pdfContext.draw(image.cgImage!, in: CGRect.init(x: 0.0, y: 0, width: Double(image.size.width), height: Double(image.size.height)))
        pdfContext.endPage()
    }
    
    return pdfData
}
