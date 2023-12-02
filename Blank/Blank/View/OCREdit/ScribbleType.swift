//
//  ScrribleType.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import Foundation
import AVKit

enum ScribbleType: Int16, CaseIterable {
    case write = 0
    case delete
    case select
    case insert
    case link

    var video: URL {
        switch self {
        case .write:
            return Bundle.main.url(forResource: "handWrite", withExtension: "mov")!
        case .insert:
            return Bundle.main.url(forResource: "insert", withExtension: "mov")!
        case .select:
            return Bundle.main.url(forResource: "select", withExtension: "mov")!
        case .delete:
            return Bundle.main.url(forResource: "delete", withExtension: "mov")!
        case .link:
            return Bundle.main.url(forResource: "link", withExtension: "mov")!
        }
    }

    var description: String {
        switch self {
        case .write:
//            return "손글씨"
            return "Writing"
        case .delete:
//            return "삭제"
            return "Delete"
        case .select:
//            return "선택"
            return "Select"
        case .insert:
//            return "삽입"
            return "Insert"
        case .link:
//            return "연결"
            return "Connect"
        }
    }

    var explain: String {
        switch self {
        case .write:
//            return "텍스트 영역에 펜슬로 글을 쓰면 인쇄체 텍스트로 전환됩니다. 아래 \n 박스에 손글씨를 써서 손글씨 입력을 사용해 보십시요."
            return "Writing with a pencil in the text area converts to printed text.\nTry using handwriting input by writing in the box below."
        case .delete:
//            return "편집 가능한 텍스트 위로 줄을 지지직 그으면 제거됩니다. \n 단어에 가로 또는 세로로 줄을 지지직 그어 아래 박스에서 \n 단어를 삭제하십시오."
            return "Zigzag lines over editable text will remove it.\nDraw horizontal or vertical zigzag lines over words to delete them in the box below."
        case .select:
//            return "텍스트에 동그라미를 치거나 선을 그어 선택합니다. 옵션을 \n 표시하려면 아래 박스에서 단어를 선택해 보십시오."
            return "Circle or draw a  line on the text to select.\nChoose a word in the box below to display options."
        case .insert:
//            return "Apple Pencil로 편집 가능한 필드 아무 곳이나 길게 탭하여 추가 \n 텍스트를 쓸 공간을 만듭니다."
            return "Long tap anywhere on the editable field with Apple Pencil\nto create space for additional text."
        case .link:
//            return "문자 앞이나 뒤에 수직 선을 그어 문자를 합치거나 \n 단어를 분리합니다."
            return "Draw vertical lines before or after characters to combine or separate them."
        }
    }

    var text: (String, String) {
        switch self {
        case .write:
//            return ("여기에 글자를 써보세요", "")
            return ("Try writing letters here.", "")
        case .delete:
//            return ("", "단어 위로 줄을 지지직 그어 빠르게 삭제하십시오.")
            return ("", "Quickly delete by zigzagging over the word.")
        case .select:
//            return ("", "단어 위로 선을 긋거나 단어에 동그라미를 쳐서 선택합니다.")
            return ("", "Draw a line over the word or circle it to select.")
        case .insert:
//            return ("", "여기에 글자를 써보세요.")
            return ("", "Try writing letters here.")
        case .link:
//            return ("", "단어에 수직 선을 그어분리하거나 합 치십시오.")
            return ("", "Draw vertical lines over the word to separate or combine.")
        }
    }
}

