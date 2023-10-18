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

func createPDFFromUIImages(from images: [UIImage]) -> NSMutableData {
    var pageHeight = 0.0
    var pageWidth = 0.0
    
    // 페이지 사이즈 정하기
    for image in images {
        pageHeight = pageHeight + Double(image.size.height)
        
        if Double(image.size.width) > pageWidth {
            pageWidth = Double(image.size.width)
        }
    }
    
    let pdfData = NSMutableData()
    let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
    
    var mediaBox = CGRect.init(x: 0, y: 0, width: pageWidth, height: pageHeight)
    let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
    
    for image in images {
        print(image, image.hash)
        var mediaBox2 = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        pdfContext.beginPage(mediaBox: &mediaBox2)
        pdfContext.draw(image.cgImage!, in: CGRect.init(x: 0.0, y: 0, width: pageWidth, height: Double(image.size.height)))
        pdfContext.endPage()
    }
    
    return pdfData
}
