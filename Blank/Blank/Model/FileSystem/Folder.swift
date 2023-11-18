//
//  Folder.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/16.
//

import Foundation

struct Folder: Codable, Equatable, Hashable, Identifiable, FileSystem {
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id && lhs.fileURL == rhs.fileURL
    }
    
    var id: UUID
    var fileURL: URL
    var fileName: String
    var subfolder: [Folder]?
}
