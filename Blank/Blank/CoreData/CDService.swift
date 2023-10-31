//
//  CDService.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/20.
//

import Foundation
import CoreData

fileprivate protocol IsCDService {
    
    /*
     ========== Create ==========
     */
    
    /// 새 File 생성: 새 문서 추가 또는 그 외의 경로로 추가되었을 때
    func createFile(from file: File) throws
    
    /// 페이지 내부에 세션 생성
    func appendSession(to page: Page, session: Session) throws
    
    /// 세션 내부에 단어들 생성
    func appendAllWords(to session: Session, words: [Word]) throws
    
    /*
     ========== Read ==========
     */
    
    /// 전체 File들 읽기
    func readFiles() throws -> [File]
    
    /// 파일 URL로부터 한 개의 File 읽기
    func readFile(from url: URL) throws -> File?
    
    /// 파일 이름으로부터 한 개의 File 읽기
    func readFile(from fileName: String) throws -> File?
    
    /// ID로부터 한 개의 File 읽기
    func readFile(id: UUID) throws -> File?
    
    /// 파일 오브젝트로부터 모든 페이지를 읽기
    func loadAllPages(of file: File) throws -> [Page]
    
    /// ID로부터 한 개의 Page 읽기
    func readPage(id: UUID) throws -> Page?
    
    /// 페이지 오브젝트로부터 모든 세션 읽기
    func loadAllSessions(of page: Page) throws -> [Session]
    
    /// ID로부터 한 개의 Session 읽기
    func readSession(id: UUID) throws -> Session?
    
    /// 세션 오브젝트로부터 모든 단어 읽기
    func loadAllWords(of session: Session) throws -> [Word]
    
    /// ID로부터 한 개의 Word 읽기
    func readWord(id: UUID) throws -> Word?
    
    /*
     ========== Update ==========
     */
    
    /// File 업데이트: 새 문서 추가 또는 그 외의 경로로 추가되었을 때
    func updateFile(to file: File) throws
    
    /// 파일 내부에 페이지 전체 업데이트
    func updateAllPages(pages: [Page], to file: File) throws
    
    /// 세션 내부에 단어들 전체 업데이트
    func updateAllWords(of session: Session, words: [Word]) throws
    
    /*
     ========== Delete ==========
     모든 relationship은 cascade 방식 (상위 오브젝트를 삭제하면 하위 오브젝트는 전부 삭제됨)
     */
    
    /// File 삭제
    func deleteFile(_ file: File) throws
    
    /// Page 삭제
    func deletePage(_ page: Page) throws
    
    /// Session 삭제
    func deleteSession(_ session: Session) throws
    
    /// Word 삭제
    func deleteWord(_ word: Word) throws
}

enum CDServiceError: Error {
    case entityAlreadyExist
}

class CDService: IsCDService {
    static let shared = CDService()
    private init() {}
    
    private var viewContext = PersistenceController.shared.container.viewContext
    
    private func readEntity<T: NSManagedObject>(id: UUID) throws -> T? {
        // Entity의 fetchRequest 생성
        let fetchRequest = T.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        return try viewContext.fetch(fetchRequest).first as? T
    }
    
    private func addAllWordsToSessionEntity(to sessionEntity: SessionEntity, words: [Word]) throws {
        words.forEach { word in
            let wordEntity = WordEntity(context: viewContext)
            wordEntity.id = word.id
            wordEntity.sessionId = sessionEntity.id
            wordEntity.isCorrect = word.isCorrect
            wordEntity.rect = word.rect.stringValue
            wordEntity.wordValue = word.wordValue
            
            sessionEntity.addToWords(wordEntity)
        }
        
        try viewContext.save()
    }
    
    func createFile(from file: File) throws {
        let fileEntity = FileEntity(context: viewContext)
        fileEntity.id = file.id
        fileEntity.fileName = file.fileName
        fileEntity.fileURL = file.fileURL
        fileEntity.totalPageCount = file.totalPageCount.int16
        
        // for page in file.pages {
        //     let pageEntity = PageEntity(context: viewContext)
        //     pageEntity.id = page.id
        //     pageEntity.currentPageNumber = page.currentPageNumber.int16
        //     pageEntity.fileId = file.id
        //     pageEntity.rect = page.basicWordCGRects.map({ $0.stringValue })
        //     
        //     fileEntity.addToPages(pageEntity)
        // }
        
        try viewContext.save()
    }
    
    func appendSession(to page: Page, session: Session) throws {
        guard let pageEntity: PageEntity = try readEntity(id: page.id) else {
            return
        }
        
        let sessionEntity = SessionEntity(context: viewContext)
        sessionEntity.id = session.id
        sessionEntity.pageId = pageEntity.id
        pageEntity.addToSessions(sessionEntity)
        
        try viewContext.save()
    }
    
    func appendAllWords(to session: Session, words: [Word]) throws {
        guard let sessionEntity: SessionEntity = try readEntity(id: session.id) else {
            return
        }
        
        try addAllWordsToSessionEntity(to: sessionEntity, words: words)
    }
    
    func readFiles() throws -> [File] {
        // Entity의 fetchRequest 생성
        let fetchRequest = FileEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        let entities = try viewContext.fetch(fetchRequest)
        let files: [File] = entities.compactMap { fileEntity in
            if let id = fileEntity.id,
               let fileName = fileEntity.fileName,
               let fileURL = fileEntity.fileURL {
                return File(
                    id: id,
                    fileURL: fileURL,
                    fileName: fileName,
                    totalPageCount: Int(fileEntity.totalPageCount)
                )
            } else {
                return nil
            }
        }
        
        return files
    }
    
    func readFile(from url: URL) throws -> File? {
        // Entity의 fetchRequest 생성
        let fetchRequest = FileEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "fileURL = %@", url.absoluteString)
        
        guard let fileEntity = try viewContext.fetch(fetchRequest).first,
              let id = fileEntity.id,
              let fileName = fileEntity.fileName,
              let fileURL = fileEntity.fileURL else {
            return nil
        }
        
        return File(
            id: id,
            fileURL: fileURL,
            fileName: fileName,
            totalPageCount: Int(fileEntity.totalPageCount)
        )
    }
    
    func readFile(from fileName: String) throws -> File? {
        // Entity의 fetchRequest 생성
        let fetchRequest = FileEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "fileName = %@", fileName)
        
        guard let fileEntity = try viewContext.fetch(fetchRequest).first,
              let id = fileEntity.id,
              let fileName = fileEntity.fileName,
              let fileURL = fileEntity.fileURL else {
            return nil
        }
        
        return File(
            id: id,
            fileURL: fileURL,
            fileName: fileName,
            totalPageCount: Int(fileEntity.totalPageCount)
        )
    }
    
    func loadAllPages(of file: File) throws -> [Page] {
        // Entity의 fetchRequest 생성
        let fetchRequest = PageEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "fileId = %@", file.id.uuidString)
        
        let entities = try viewContext.fetch(fetchRequest)
        let pages: [Page] = entities.compactMap { pageEntity in
            if let id = pageEntity.id,
               let fileId = pageEntity.fileId,
               let rects = pageEntity.rect {
                return Page(
                    id: id,
                    fileId: fileId,
                    currentPageNumber: Int(pageEntity.currentPageNumber)
                )
            } else {
                return nil
            }
        }
        
        return pages
    }
    
    func loadAllSessions(of page: Page) throws -> [Session] {
        // Entity의 fetchRequest 생성
        let fetchRequest = SessionEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "pageId = %@", page.id.uuidString)
        
        let entities = try viewContext.fetch(fetchRequest)
        let sessions: [Session] = entities.compactMap { sessionEntity in
            if let id = sessionEntity.id,
               let pageId = sessionEntity.pageId {
                return Session(id: id, pageId: pageId)
            } else {
                return nil
            }
        }
        
        return sessions
    }
    
    func loadAllWords(of session: Session) throws -> [Word] {
        // Entity의 fetchRequest 생성
        let fetchRequest = WordEntity.fetchRequest()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "sessionId = %@", session.id.uuidString)
        
        let entities = try viewContext.fetch(fetchRequest)
        let words: [Word] = entities.compactMap { wordEntity in
            if let id = wordEntity.id,
               let rect = wordEntity.rect?.cgRect,
               let sessionId = wordEntity.sessionId,
               let wordValue = wordEntity.wordValue {
                return Word(
                    id: id,
                    sessionId: sessionId,
                    wordValue: wordValue,
                    rect: rect,
                    isCorrect: wordEntity.isCorrect
                )
            } else {
                return nil
            }
        }
        
        return words
    }
    
    func updateFile(to file: File) throws {
        guard let fileEntity: FileEntity = try readEntity(id: file.id) else {
            return
        }
        
        fileEntity.id = file.id
        fileEntity.fileName = file.fileName
        fileEntity.fileURL = file.fileURL
        fileEntity.totalPageCount = file.totalPageCount.int16
        
        try viewContext.save()
    }
    
    func updateAllPages(pages: [Page], to file: File) throws {
        guard let fileEntity: FileEntity = try readEntity(id: file.id) else {
            return
        }
        
        for page in pages {
            let pageEntity = PageEntity(context: viewContext)
            pageEntity.id = page.id
            pageEntity.currentPageNumber = page.currentPageNumber.int16
            pageEntity.fileId = file.id
            // pageEntity.rect = page.basicWordCGRects.map({ $0.stringValue })
            
            fileEntity.addToPages(pageEntity)
        }
        
        try viewContext.save()
    }
    
    func updateAllWords(of session: Session, words: [Word]) throws {
        guard let sessionEntity: SessionEntity = try readEntity(id: session.id) else {
            return
        }
        
        sessionEntity.words = NSSet()
        
        try addAllWordsToSessionEntity(to: sessionEntity, words: words)
    }
    
    func deleteFile(_ file: File) throws {
        guard let fileEntity: FileEntity = try readEntity(id: file.id) else {
            return
        }
        
        do {
            viewContext.delete(fileEntity)
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func deletePage(_ page: Page) throws {
        guard let pageEntity: PageEntity = try readEntity(id: page.id) else {
            return
        }
        
        do {
            viewContext.delete(pageEntity)
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func deleteSession(_ session: Session) throws {
        guard let sessionEntity: SessionEntity = try readEntity(id: session.id) else {
            return
        }
        
        do {
            viewContext.delete(sessionEntity)
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func deleteWord(_ word: Word) throws {
        guard let wordEntity: WordEntity = try readEntity(id: word.id) else {
            return
        }
        
        do {
            viewContext.delete(wordEntity)
            try viewContext.save()
        } catch {
            print(error)
        }
    }
  
    func readFile(id: UUID) throws -> File? {
        guard let fileEntity: FileEntity = try readEntity(id: id),
              let id = fileEntity.id,
              let fileName = fileEntity.fileName,
              let fileURL = fileEntity.fileURL else {
            return nil
        }
        
        return File(
            id: id,
            fileURL: fileURL,
            fileName: fileName,
            totalPageCount: Int(fileEntity.totalPageCount)
        )
    }
    
    func readPage(id: UUID) throws -> Page? {
        guard let pageEntity: PageEntity = try readEntity(id: id),
              let id = pageEntity.id,
              let fileId = pageEntity.fileId,
              let rects = pageEntity.rect else {
            return nil
        }
        
        return Page(
            id: id,
            fileId: fileId,
            currentPageNumber: Int(pageEntity.currentPageNumber)
        )
    }
    
    func readSession(id: UUID) throws -> Session? {
        guard let sessionEntity: SessionEntity = try readEntity(id: id),
              let id = sessionEntity.id,
              let pageId = sessionEntity.pageId else {
            return nil
        }
              
        return Session(id: id, pageId: pageId)
    }
    
    func readWord(id: UUID) throws -> Word? {
        guard let wordEntity: WordEntity = try readEntity(id: id),
              let id = wordEntity.id,
              let rect = wordEntity.rect?.cgRect,
              let sessionId = wordEntity.sessionId,
              let wordValue = wordEntity.wordValue else {
            return nil
        }
        
        return Word(
            id: id,
            sessionId: sessionId,
            wordValue: wordValue,
            rect: rect,
            isCorrect: wordEntity.isCorrect
        )
    }
}
