//
//  ScrribleType.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import Foundation
import AVKit

enum ScrribleType: Int16, CaseIterable {
    case write = 0
    case delete
    case select
    case insert
    case link

    var video: AVPlayer {
        switch self {
        case .write:
            return AVPlayer(url: Bundle.main.url(forResource: "handWrite", withExtension: "mov")!)
        case .insert:
            return AVPlayer(url: Bundle.main.url(forResource: "insert", withExtension: "mov")!)
        case .select:
            return AVPlayer(url: Bundle.main.url(forResource: "select", withExtension: "mov")!)
        case .delete:
            return AVPlayer(url: Bundle.main.url(forResource: "delete", withExtension: "mov")!)
        case .link:
            return AVPlayer(url: Bundle.main.url(forResource: "link", withExtension: "mov")!)
        }
    }

    var description: String {
        switch self {
        case .write:
            return "손글씨"
        case .delete:
            return "삭제"
        case .select:
            return "선택"
        case .insert:
            return "삽입"
        case .link:
            return "연결"
        }
    }

    var explain: String {
        switch self {
        case .write:
            return "텍스트 영역에 펜슬로 글을 쓰면 인쇄체 텍스트로 전환됩니다. 아래 \n 박스에 손글씨를 써서 손글씨 입력을 사용해 보십시요."
        case .delete:
            return "편집 가능한 텍스트 위로 줄을 지지직 그으면 제거됩니다. \n 단어에 가로 또는 세로로 줄을 지지직 그어 아래 박스에서 \n 단어를 삭제하십시오."
        case .select:
            return "텍스트에 동그라미를 치거나 선을 그어 선택합니다. 옵션을 \n 표시하려면 아래 박스에서 단어를 선택해 보십시오."
        case .insert:
            return "Apple Pencil로 편집 가능한 필드 아무 곳이나 길게 탭하여 추가 \n 텍스트를 쓸 공간을 만듭니다."
        case .link:
            return "문자 앞이나 뒤에 수직 선을 그어 문자를 합치거나 \n 단어를 분리합니다."
        }
    }
}

