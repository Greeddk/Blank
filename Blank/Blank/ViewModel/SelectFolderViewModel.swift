//
//  SelectFolderViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/19.
//

import Foundation

class SelectFolderViewModel: ObservableObject {
    @Published private(set) var directoryList: [Folder] = []
    
    init() {
        guard let documentDirectoryURL = FileManager.documentDirectoryURL,
              let nextFolder = try? directoryContents(at: documentDirectoryURL).first else {
            return
        }
        
        var rootFolder: Folder = .init(id: .init(), fileURL: FileManager.documentDirectoryURL!, fileName: "Document", subfolder: [])
        directoryListRecursively(parentFolder: &rootFolder, nextURL: nextFolder.absoluteURL)
        
        directoryList = [rootFolder]
    }
    
    func directoryContents(at targetDirectoryURL: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(
            at: targetDirectoryURL,
            includingPropertiesForKeys: nil
        ).filter {
            $0.hasDirectoryPath
        }
    }
    
    func directoryListRecursively(parentFolder: inout Folder, nextURL: URL) {
        guard let directoryContents = try? directoryContents(at: nextURL) else {
            return
        }
        
        guard parentFolder.subfolder != nil else {
            return
        }
        
        // guard let을 쓰지 않고 강제 언래핑 하는 이유: 배열에 직접 접근해서 값을 바꾸려고
        
        if directoryContents.isEmpty {
            parentFolder.subfolder!.append(.init(id: .init(), fileURL: nextURL, fileName: nextURL.lastPathComponent, subfolder: nil))
            return
        }
        
        parentFolder.subfolder!.append(.init(id: .init(), fileURL: nextURL, fileName: nextURL.lastPathComponent, subfolder: []))
        
        let lastCount = parentFolder.subfolder!.count - 1
        for directoryContent in directoryContents {
            directoryListRecursively(parentFolder: &parentFolder.subfolder![lastCount], nextURL: directoryContent.absoluteURL)
        }
    }
}
