//
//  ScrribleVideoView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScrribleVideoView: View {
    @State var player: AVPlayer?
    @Binding var selectedType: ScrribleType
    @Binding var hasTypeValueChanged: Bool

    var body: some View {

        VideoPlayer(player: player)
            .onAppear() {
                player?.play()
            }
            .frame(width: 550 ,height: 100)
            .onChange(of: selectedType) { newValue in
                if newValue != ScrribleType.write {
                    player = selectedType.video
                    player?.play()
                }
            }
            .onDisappear {
                player?.pause()
                player?.seek(to: .zero)
            }
    }
}

#Preview {
    ScrribleVideoView(selectedType: .constant(ScrribleType.write), hasTypeValueChanged: .constant(false))
}
