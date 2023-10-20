//
//  PersistenceView.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/16.
//

import SwiftUI
import CoreData

/*
  코어데이터 설치 여부를 확인하기 위한 임시 뷰로 확인 완료되면 삭제할 예정입니다.
 */
struct PersistenceView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FileEntity.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<FileEntity>
    
    @ViewBuilder func wordsView(_ words: [WordEntity]) -> some View {
        ScrollView {
            ForEach(words) { wordEntity in
                HStack {
                    Text(wordEntity.id?.uuidString ?? "unknown")
                        .foregroundStyle(.gray)
                    Text(wordEntity.wordValue ?? "")
                }
            }
        }
    }
    
    @ViewBuilder func sessionsView(_ sessions: [SessionEntity]) -> some View {
        ForEach(sessions) { sessionEntity in
            HStack {
                Text(sessionEntity.id?.uuidString ?? "unknown")
                    .foregroundStyle(.gray)
                Text("Words Count: \(sessionEntity.words?.count ?? -99)")
                NavigationLink {
                    if let words = sessionEntity.words?.allObjects as? [WordEntity] {
                        wordsView(words)
                    }
                } label: {
                    Text("[단어 보기]")
                }
            }
        }
    }
    
    @ViewBuilder func pagesView(_ pages: [PageEntity]) -> some View {
        ForEach(pages) { pageEntity in
            HStack {
                Text(pageEntity.id?.uuidString ?? "unknown")
                    .foregroundStyle(.gray)
                Text("currentPageNumber: \(pageEntity.currentPageNumber)")
                Text("CDRect: \(pageEntity.rect?.x ?? 0)")
                Text("session 수: \(pageEntity.sessions?.count ?? -99)")
                NavigationLink {
                    if let sessions = pageEntity.sessions?.allObjects as? [SessionEntity] {
                        sessionsView(sessions)
                    }
                } label: {
                    Text("[세션 보기]")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { fileEntity in
                    NavigationLink {
                        Text("파일 ID: \(fileEntity.id?.uuidString ?? "unknown")")
                        Text("Pages 수: \(fileEntity.pages?.count ?? -99)")
                        NavigationLink {
                            if let pages = fileEntity.pages?.allObjects as? [PageEntity] {
                                pagesView(pages)
                            }
                        } label: {
                            Text("[페이지 보기]")
                        }
                    } label: {
                        Text(fileEntity.fileName ?? "unknown")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            // let newPage = PageEntity(context: viewContext)
            // newPage.currentPageNumber = 900 + Int16.random(in: 1...100)
            // newPage.fileId = UUID()
            // newPage.id = UUID()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    PersistenceView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
