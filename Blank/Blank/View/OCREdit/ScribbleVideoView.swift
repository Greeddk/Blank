//
//  ScrribleVideoView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScribbleVideoView: View {
    @StateObject var playerViewModel: PlayerViewModel

    var body: some View {
        VStack {
            PlayerUIView(playerViewModel: playerViewModel)
                .frame(width: 600, height: 100)
                .disabled(true)
                .onAppear() {
                    playerViewModel.player = playerViewModel.selectedType.video
                    playerViewModel.player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerViewModel.player.currentItem, queue: .main) { _ in
                        playerViewModel.player.seek(to: CMTime.zero)
                        playerViewModel.player.play()
                    }
                }
                .onChange(of: playerViewModel.selectedType) { newValue in
                    playerViewModel.player = newValue.video
                    playerViewModel.player.seek(to: CMTime.zero)
                    playerViewModel.player.play()
                }
                .onDisappear {
                    playerViewModel.player.pause()
                    playerViewModel.player.seek(to: .zero)
                    
                }
        }
    }
}


