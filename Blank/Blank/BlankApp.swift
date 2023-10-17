//
//  BlankApp.swift
//  Blank
//
//  Created by Sup on 10/12/23.
//

import SwiftUI

@main
struct BlankApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
}
