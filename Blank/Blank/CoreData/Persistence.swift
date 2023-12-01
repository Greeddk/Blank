//
//  Persistence.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/16.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController(inMemory: true)

    /// 코어데이터 미리보기 용도로 FileEntity 엔티티 생성
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<10 {
            let newFile = FileEntity(context: viewContext)
            let uuid = UUID()
            newFile.id = uuid
            newFile.fileName = "\(uuid.uuidString).pdf"
            newFile.fileURL = .init(string: "https://google.com")
            newFile.totalPageCount = 1000
            
            // 페이지 생성
            let pageEnd = Int.random(in: 5...30)
            for _ in 0..<pageEnd {
                let pageId = UUID()
                
                let page = PageEntity(context: viewContext)
                page.id = pageId
                page.currentPageNumber = Int16.random(in: Int16(2)...Int16(pageEnd))
                page.fileId = uuid

                // 세션 생성
                for _ in 0..<Int.random(in: 0...15) {
                    let sessionId = UUID()
                    let session = SessionEntity(context: viewContext)
                    session.id = sessionId
                    session.pageId = pageId
                    
                    // 워드 생성
                    for i in 0..<Int.random(in: 0...200) {
                        let word = WordEntity(context: viewContext)
                        word.isCorrect = Bool.random()
                        word.id = UUID()
                        word.sessionId = sessionId
                        word.wordValue = "WORD\(i)"
                        
                        
                        session.addToWords(word)
                    }
                    page.addToSessions(session)
                }
                newFile.addToPages(page)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Blank")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

