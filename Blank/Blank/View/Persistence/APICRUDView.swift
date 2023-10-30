//
//  APICRUDView.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/23.
//

import SwiftUI

struct APICRUDView: View {
    @State var files: [File]?
    @State var pages: [Page]?
    @State var sessions: [Session]?
    @State var words: [Word]?
    
    var body: some View {
        VStack {
            Text("API CRUD View")
                    .font(.largeTitle)
            ScrollView {
                ForEach(files ?? [], id: \.id) { file in
                    Text("\(file.fileName)")
                }
                
                ForEach(pages ?? [], id: \.id) { page in
                    Text("Page: \(page.id), \(page.basicWords.first?.rect.stringValue ?? "")")
                }
                
                ForEach(sessions ?? [], id: \.id) { session in
                    Text("Session: \(session.id)")
                }
                
                ForEach(words ?? [], id: \.id) { word in
                    Text(":: \(word.wordValue)")
                }
            }
            
        }
        .onAppear {
            let fileUUID = UUID(uuidString: "efd4461f-8e02-4cb2-9543-be20a20e8538")!
            let file: File = .init(
                id: fileUUID,
                fileURL: Bundle.main.url(forResource: "sample", withExtension: "pdf")!,
                fileName: "\(fileUUID).pdf",
                totalPageCount: 500)
            do {
                // File
                try CDService.shared.createFile(from: file)
                
                files = try CDService.shared.readFiles()
                
                try CDService.shared.updateFile(to: .init(
                    id: fileUUID,
                    fileURL: Bundle.main.url(forResource: "sample", withExtension: "pdf")!,
                    fileName: "dkdkdkdk.pdf",
                    totalPageCount: 500))
                
                try CDService.shared.deleteFile(.init(
                    id: fileUUID,
                    fileURL: Bundle.main.url(forResource: "sample", withExtension: "pdf")!,
                    fileName: "dkdkdkdk.pdf",
                    totalPageCount: 500))
                
                // Page
                let page2Id = UUID()
                let page1: Page = .init(id: UUID(), fileId: fileUUID, currentPageNumber: 15, basicWordCGRects: [.init(x: 0, y: 35, width: 484.44, height: 3939.434)])
                let page2: Page = .init(id: page2Id, fileId: fileUUID, currentPageNumber: 15, basicWordCGRects: [.init(x: 466, y: 335, width: 4.44, height: 39.411111)])
                
                try CDService.shared.updateAllPages(pages: [
                    page1, page2], to: file)
                
                pages = try CDService.shared.loadAllPages(of: file)
                
                try CDService.shared.deletePage(page1)
                
                // Session & Word
                let sessionID = UUID()
                let session: Session = .init(id: sessionID, pageId: page2Id)
                try CDService.shared.appendSession(to: page2, session: session)
                // try CDService.shared.appendAllWords(to: session, words: [
                //     .init(id: UUID(), sessionId: sessionID, wordValue: "WORD:\(UUID().uuidString)", rect: .zero),
                //     .init(id: UUID(), sessionId: sessionID, wordValue: "WORD:\(UUID().uuidString)", rect: .zero),
                //     .init(id: UUID(), sessionId: sessionID, wordValue: "WORD:\(UUID().uuidString)", rect: .zero),
                // ])
                
                sessions = try CDService.shared.loadAllSessions(of: page2)
                words = try CDService.shared.loadAllWords(of: session)
                
                try CDService.shared.updateAllWords(of: session, words: [.init(id: UUID(), sessionId: sessionID, wordValue: "WWL:EDITTT", rect: .zero)])
                words = try CDService.shared.loadAllWords(of: session)
                
                try CDService.shared.deleteSession(session)
                // sessions = try CDService.shared.loadAllSessions(of: page2)
            } catch {
                print("API Error:", error)
            }
            
            
        }
    }
}

#Preview {
    APICRUDView()
}
