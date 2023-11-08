//
//  PlayerUIView.swift
//  Blank
//
//  Created by 조용현 on 11/1/23.
//

import SwiftUI
import UIKit
import AVKit

struct PlayerView: UIViewRepresentable {
    @Binding var player: AVQueuePlayer?

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let player = player else { return }

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = uiView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        uiView.layer.addSublayer(playerLayer)
    }

    func makeUIView(context: Context) -> UIView {
        let playerLayer = AVPlayerLayer(player: player)

        return UIView()
    }
}
