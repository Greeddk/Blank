//
//  TutorialAppStorageKeys.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/22.
//

import Foundation

func resetTutorialKeysForTestOnly() {
    let userDefaults = UserDefaults.standard
    
    userDefaults.setValue(true, forKey: .tutorialOverView)
    userDefaults.setValue(true, forKey: .tutorialWordSelectView)
    userDefaults.setValue(true, forKey: .tutorialOCREditView)
    userDefaults.setValue(true, forKey: .tutorialTestPageView)
    userDefaults.setValue(true, forKey: .tutorialResultPageView)
}

extension String {
    
    static let tutorialOverView = "tutorialOverView"
    static let tutorialWordSelectView = "tutorialWordSelectView"
    static let tutorialOCREditView = "tutorialOCREditView"
    static let tutorialTestPageView = "tutorialTestPageView"
    static let tutorialResultPageView = "tutorialResultPageView"
}
