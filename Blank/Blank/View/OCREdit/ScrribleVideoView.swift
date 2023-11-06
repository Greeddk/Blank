//
//  ScrribleVideoView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScrribleVideoView: View {
    @State var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "handWrite", withExtension: "mov")!)
    @Binding var selectedType: ScrribleType

    var body: some View {
        VStack {
            PlayerUIView(player: player)
                .frame(width: 600, height: 100)
                .disabled(true)
                .onAppear() {
//                    player = selectedType.video
                    player.play()
//                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
//                        player.seek(to: .zero)
//                        player.play()
//                    }
                }

                .onChange(of: selectedType) { newValue in
                    player = newValue.video
                    player.seek(to: .zero)
                    player.play()

                }
                .onDisappear {
                    player.pause()
                    player.seek(to: .zero)

                }
        }
    }
}
