//
//  File.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import Foundation

struct File: Codable, Equatable, Hashable, FileSystem {
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id && lhs.fileURL == rhs.fileURL
    }
    
    var id: UUID
    var fileURL: URL
    var fileName: String
    /// PDF 문서의 총 페이지를 표시하기 위한 변수
    var totalPageCount: Int
    var solvedPageCount: Int = 0
}
