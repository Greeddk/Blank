//
//  PlayerViewModel.swift
//  Blank
//
//  Created by 조용현 on 11/7/23.
//

import SwiftUI
import AVKit

class PlayerViewModel: ObservableObject {
//    @Published var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "handWrite", withExtension: "mov")!)
    @Published var selectedType: ScribbleType = ScribbleType.write {
        didSet {
            let playerItem = AVPlayerItem(url: selectedType.video)
            player = AVQueuePlayer(playerItem: playerItem)
            playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem)
        }
    }
    @Published var hasTypeValueChanged: Bool = false
    @Published var player: AVQueuePlayer?
    @Published var playerLooper: AVPlayerLooper?
}
