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
