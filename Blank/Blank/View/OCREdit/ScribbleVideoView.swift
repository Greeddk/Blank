//
//  ScrribleVideoView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScribbleVideoView: View {
    @ObservedObject var playerViewModel: PlayerViewModel

    var body: some View {
        VStack {
            PlayerUIView(playerViewModel: playerViewModel)
                .frame(width: 600, height: 100)
                .disabled(true)
                .onAppear() {
                    print("selectedType", playerViewModel.selectedType)
                    print("selectedType", playerViewModel.player)

                    playerViewModel.player = playerViewModel.selectedType.video
                    playerViewModel.player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerViewModel.player.currentItem, queue: .main) { _ in
                        playerViewModel.player.seek(to: CMTime.zero)
                        playerViewModel.player.play()
                    }
                }
                .onChange(of: playerViewModel.selectedType) { newValue in
                    print("selectedType", playerViewModel.selectedType)
                    print("selectedType", playerViewModel.player)
                    print("selectedType", newValue)

                    playerViewModel.player = newValue.video
                    playerViewModel.player.play()
//                    text = newValue.text.1
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerViewModel.player.currentItem, queue: .main) { _ in
                        playerViewModel.player.seek(to: CMTime.zero)
                        playerViewModel.player.play()
                    }
                }
                .onDisappear {
                    playerViewModel.player.pause()
                    playerViewModel.player.seek(to: .zero)

                }
        }
    }
}

class PlayerViewModel: ObservableObject {
    @Published var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "handWrite", withExtension: "mov")!)
    @Published var selectedType: ScribbleType = ScribbleType.write
    @Published var hasTypeValueChanged: Bool = false
}
