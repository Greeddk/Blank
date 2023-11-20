//
//  FileMananger+.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/16.
//

import Foundation

extension FileManager {
    /// 파일을 복사하는 기능
    public func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("[DEBUG] Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        
        return true
    }
    
    /// 삭제
    public func delete(at srcURLs: [URL]) {
        for url in srcURLs {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    // print("Delete success: \(url)")
                } catch {
                    print("Cannot delete item at \(url) : \(error)")
                }
            }
        }
    }
    
    /// 파일 이동
    public func move(urls: [URL], to destination: URL) {
        guard destination.hasDirectoryPath else {
            return
        }
        
        for url in urls {
            do {
                let targetURL = destination.appendingPathComponent(url.lastPathComponent)
                try FileManager.default.moveItem(at: url, to: targetURL)
            } catch {
                print(error)
            }
        }
    }
    
    /// Document 디렉토리 URL
    static let documentDirectoryURL = try? FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
}

