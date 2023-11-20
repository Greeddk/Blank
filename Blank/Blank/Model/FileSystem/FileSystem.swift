//
//  FileSystem.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/16.
//

import Foundation

protocol FileSystem {
    var id: UUID { get set }
    var fileURL: URL { get set }
    var fileName: String { get set }
}
