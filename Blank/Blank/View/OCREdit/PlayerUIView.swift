//
//  PlayerUIView.swift
//  Blank
//
//  Created by 조용현 on 11/1/23.
//

import SwiftUI
import UIKit
import AVKit

struct PlayerUIView: UIViewRepresentable {
    var player: AVPlayer

    func updateUIView(_ uiView: UIView, context: Context) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = uiView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        uiView.layer.addSublayer(playerLayer)
        player.play()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        player.play()

        return UIView()
    }
}
