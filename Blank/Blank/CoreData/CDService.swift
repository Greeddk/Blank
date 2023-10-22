//
//  CDService.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/20.
//

import Foundation
import CoreData

protocol IsCDService {
    
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
    func readWord(id: UUID) throws -> File?
    
    /*
     ========== Update ==========
     */
    
    /// File 업데이트: 새 문서 추가 또는 그 외의 경로로 추가되었을 때
    func updateFile(to file: File) throws
    
    /// 파일 내부에 페이지 전체 업데이트
    func updateAllPages(from: [Page], to file: File) throws
    
    /// 페이지 내부에 세션 생성
    func updateSession(of page: Page, to session: Session) throws
    
    /// 세션 내부에 단어들 생성
    func updateAllWords(of session: Session) throws
    
    /*
     ========== Delete ==========
     모든 relationship은 cascade 방식 (상위 오브젝트를 삭제하면 하위 오브젝트는 전부 삭제됨)
     */
    
    /// File 삭제
    func deleteFile(_ file: File) throws
    
    /// Page 삭제
    func deletePage(_ page: Page) throws
    
    /// Session 삭제
    func deleteSession(_ page: Session) throws
    
    /// Word 삭제
    func deleteWord(_ page: Word) throws
}

class CDService: IsCDService {
    static let shared = CDService()
    private init() {}
    
    var viewContext = PersistenceController.shared.container.viewContext
    
    private func readEntity<T: NSFetchRequestResult>(id: UUID) throws -> T? {
        // Entity의 fetchRequest 생성
        let fetchRequest = NSFetchRequest<T>()
        
        // 정렬 또는 조건 설정
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        return try viewContext.fetch(fetchRequest).first
    }
    
    func createFile(from file: File) throws {
        let entity = FileEntity(context: viewContext)
        entity.id = file.id
        entity.fileName = file.fileName
        entity.fileURL = file.fileURL
        entity.totalPageCount = file.totalPageCount.int16
        
        for page in file.pages {
            let pageEntity = PageEntity(context: viewContext)
            pageEntity.id = page.id
            pageEntity.currentPageNumber = page.currentPageNumber.int16
            pageEntity.fileId = file.id
            pageEntity.rect = page.basicWordCGRect.map({ $0.stringValue })
        }
        
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
    
    func readFiles() throws -> [File] {
        return []
    }
    
    func readFile(from url: URL) throws -> File? {
        return nil
    }
    
    func readFile(from fileName: String) throws -> File? {
        return nil
    }
    
    func loadAllPages(of file: File) throws -> [Page] {
        return []
    }
    
    func loadAllSessions(of page: Page) throws -> [Session] {
        return []
    }
    
    func loadAllWords(of session: Session) throws -> [Word] {
        return []
    }
    
    func updateFile(to file: File) throws {
        
    }
    
    func updateAllPages(from: [Page], to file: File) throws {
        
    }
    
    func updateSession(of page: Page, to session: Session) throws {
        
    }
    
    func updateAllWords(of session: Session) throws {
        
    }
    
    func deleteFile(_ file: File) throws {
        
    }
    
    func deletePage(_ page: Page) throws {
        
    }
    
    func deleteSession(_ page: Session) throws {
        
    }
    
    func deleteWord(_ page: Word) throws {
        
    }
  
    func readFile(id: UUID) throws -> File? {
        nil
    }
    
    func readPage(id: UUID) throws -> Page? {
        nil
    }
    
    func readSession(id: UUID) throws -> Session? {
        nil
    }
    
    func readWord(id: UUID) throws -> File? {
        nil
    }
}
