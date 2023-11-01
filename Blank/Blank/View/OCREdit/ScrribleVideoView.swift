//
//  ScrribleVideoView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScrribleVideoView: View {
    @Binding var player: AVPlayer
    @Binding var selectedType: ScrribleType
    @Binding var hasTypeValueChanged: Bool
    
    
    
    var body: some View {
        VStack {
            PlayerUIView(player: player)
                .frame(width: 600, height: 100)
                .disabled(true)
                .onAppear() {
                    player = selectedType.video
                    player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
            
                .onChange(of: selectedType) { newValue in
                    player = newValue.video
//                    text = newValue.text.1
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
                .onDisappear {
                    player.pause()
                    player.seek(to: .zero)
                    
                }
        }
    }
}
