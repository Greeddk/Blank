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
            PlayerView(player: $playerViewModel.player)
                .frame(width: 600, height: 100)
                .disabled(true)
                .onAppear() {
                    playerViewModel.selectedType = ScribbleType.write
                    playerViewModel.player?.play()
                }
                .onChange(of: playerViewModel.selectedType) { newValue in
                    playerViewModel.player?.pause()
                    playerViewModel.player?.seek(to: .zero)
                    playerViewModel.player?.play()
                }
                .onDisappear {
                    playerViewModel.player?.pause()
                    playerViewModel.player?.seek(to: .zero)
                }
        }
    }
}


