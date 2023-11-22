//
//  BlankApp.swift
//  Blank
//
//  Created by Sup on 10/12/23.
//

import SwiftUI

@main
struct BlankApp: App {
    init() {
         HomeViewModel.copySampleFiles()
        
        // UserDefaults 리셋
        // resetTutorialKeysForTestOnly()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
