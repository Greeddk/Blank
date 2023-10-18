//
//  DummyObjects.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/18.
//

import Foundation

// SwiftUI Preview를 위한 더미 파일 모음입니다.

let DUMMY_FILE: File = .init(
    id: .init(),
    fileURL: Bundle.main.url(forResource: "sample", withExtension: "pdf")!,
    fileName: "정보처리기사 실기", 
    totalPageCount: 1200,
    pages: []
)
