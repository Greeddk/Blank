//
//  PlayerViewModel.swift
//  Blank
//
//  Created by 조용현 on 11/7/23.
//

import SwiftUI
import AVKit

class PlayerViewModel: ObservableObject {
    @Published var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "handWrite", withExtension: "mov")!)
    @Published var selectedType: ScribbleType = ScribbleType.write
    @Published var hasTypeValueChanged: Bool = false
}
