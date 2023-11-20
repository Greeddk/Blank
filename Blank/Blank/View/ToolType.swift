//
//  ToolType.swift
//  Blank
//
//  Created by 조용현 on 11/20/23.
//

import Foundation
import SwiftUI

enum ToolType: Int16, CaseIterable {
    case makeBlank = 0
    case drag
    case erase

    var description: String {
        switch self {
        case .makeBlank:
            return "빈칸만들기"
        case .drag:
            return "선택"
        case .erase:
            return "지우기"
        }
    }
    func toolImage() -> Image {
        switch self {
        case .makeBlank:
            return Image(systemName: "arrow.rectanglepath")
        case .drag:
            return Image(systemName: "arrow.rectanglepath")
        case .erase:
            return Image(systemName: "eraser.line.dashed.fill")
        }
    }
}
