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
    
    @StateObject var homeViewModel = HomeViewModel()
    
    init() {
        HomeViewModel.copySampleFiles()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                .environmentObject(homeViewModel)
            PersistenceView()
        }
    }
}
