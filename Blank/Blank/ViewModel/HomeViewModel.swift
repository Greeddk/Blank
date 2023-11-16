//
//  HomeViewModel.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/16.
//

import UIKit

class HomeViewModel: ObservableObject {
    @Published var fileList: [FileSystem] = []
    @Published var selectedFileList: Set<File> = []
    @Published var searchText = ""
    
    @Published private(set) var currentDirectoryURL: URL?
    
    init() {
        fetchDocumentFileList()
    }
    
    /// 파일 이름 자동 제안
    var suggestedFileName: String {
        // TODO: - 더 참신한 방법
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let randomGeneratedString = String((0..<5).map{ _ in letters.randomElement()! })
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMDD"
        
        return "\(formatter.string(from: Date.now))_\(randomGeneratedString)"
    }
    
    /// 검색(필터링) 결과를 출력
    /// https://www.swiftyplace.com/blog/swiftui-search-bar-best-practices-and-examples
    var filteredFileList: [FileSystem] {
        guard !searchText.isEmpty else {
            return fileList
        }
        
        return fileList.filter { info in
            let lastComponent = info.fileURL.lastPathComponent
            return lastComponent.lowercased().contains(searchText.lowercased())
        }
    }
    
    /// 현재 `currentDirectoryURL`가 위치한 곳이 루트 디렉토리인가?
    var isLocatedInRootDirectory: Bool {
        currentDirectoryURL == FileManager.documentDirectoryURL
    }
    
    func fetchDocumentFileList(from targetDirectoryURL: URL) {
        do {
            currentDirectoryURL = targetDirectoryURL
            
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: targetDirectoryURL,
                includingPropertiesForKeys: nil
            )

            self.fileList = try directoryContents.map { url in
                let solvedPageCount = try CDService.shared.loadSolvedPageCount(fileName: url.lastPathComponent)
                
                return if url.hasDirectoryPath {
                    Folder(id: UUID(), fileURL: url, fileName: url.lastPathComponent)
                } else {
                    File(id: UUID(),
                         fileURL: url,
                         fileName: url.lastPathComponent,
                         totalPageCount: pageCount(of: url) ?? 0,
                         solvedPageCount: solvedPageCount
                    )
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    /// 파일 목록을 가져와서 [File] 형태로 저장
    func fetchDocumentFileList(_ subpath: String? = nil) {
        guard var targetDirectoryURL = currentDirectoryURL ?? FileManager.documentDirectoryURL else {
            return
        }
        
        if let subpath {
            targetDirectoryURL.append(path: subpath)
        }
        
        fetchDocumentFileList(from: targetDirectoryURL)
    }
    
    func fetchFileListFromParentDirectory() {
        guard let currentDirectoryURL,
              let documentDirectoryURL = FileManager.documentDirectoryURL,
              documentDirectoryURL != currentDirectoryURL else {
            return
        }
        
        let parentDirectoryURL = currentDirectoryURL.deletingLastPathComponent()
        fetchDocumentFileList(from: parentDirectoryURL)
    }
    
    func addFileToDocument(from url: URL) {
        if copyFileToDocumentBundle(from: url) {
            fetchDocumentFileList()
        }
    }
    
    /// 파일 삭제 기능
    func removeFiles(urls: [URL]) {
        FileManager.default.delete(at: urls)
        fetchDocumentFileList()
    }
    
    /// selectedFileList에서 URL을 찾아 파일 삭제
    func removeSelectedFiles() {
        FileManager.default.delete(at: selectedFileList.compactMap({ $0.fileURL }))
        fetchDocumentFileList()
    }
    
    /// 파일을 외부로부터 문서 폴더에 추가
    /// - Returns: 파일 복사의 성공/실패 여부
    func copyFileToDocumentBundle(from fromURL: URL) -> Bool {
        // TODO: - 이미 존재하는 파일은 복사를 더 할지, 덮어쓸지, 아니면 그냥 지나칠지 물어보기
        guard let targetDirectory = currentDirectoryURL ?? FileManager.documentDirectoryURL else {
            print("[Fatal Error] toURL 폴더가 없습니다.")
            return false
        }
        
        guard fromURL.startAccessingSecurityScopedResource() else {
            return false
        }
        
        return FileManager.default.secureCopyItem(
            at: fromURL,
            to: targetDirectory.appendingPathComponent(fromURL.lastPathComponent)
        )
    }
    
    /// 예제 파일들을 Document 폴더에 복사 (처음 설치했을 때만 실행되어야 함)
    static func copySampleFiles() {
        let sampleFiles: [URL] = [
//            Bundle.main.url(forResource: "samplepdf", withExtension: "pdf"),
            Bundle.main.url(forResource: "samplePDF", withExtension: "pdf"),
//            Bundle.main.url(forResource: "sample", withExtension: "pdf"),
//            Bundle.main.url(forResource: "blank", withExtension: "pdf"),
//            Bundle.main.url(forResource: "toeic", withExtension: "pdf"),
//            Bundle.main.url(forResource: "TestA", withExtension: "pdf"),
//            Bundle.main.url(forResource: "TestB", withExtension: "pdf"),
//            Bundle.main.url(forResource: "TestC", withExtension: "pdf"),
//            Bundle.main.url(forResource: "elementarySchoolEnglishWord", withExtension: "pdf")
        ].compactMap { $0 }
        
        sampleFiles.forEach { fileURL in
            guard let newURL = FileManager.documentDirectoryURL?.appendingPathComponent(fileURL.lastPathComponent) else {
                return
            }
            
            let copyResult = FileManager.default.secureCopyItem(at: fileURL, to: newURL)
            print(newURL.lastPathComponent, " / result:", copyResult)
        }
    }
}
