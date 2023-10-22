//
//  ScrribleModalView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScrribleModalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedType: ScrribleType
    @Binding var hasTypeValueChanged: Bool
    @State var name: String = "여기에"

    var body: some View {
        VStack {
            Text("손글씨 입력 쓰기")
                .font(.title)

            HStack(spacing: 40) {
                Spacer()
                Picker("타입", selection: $selectedType) {
                    ForEach(ScrribleType.allCases, id: \.self) {
                        Text($0.description)
                    }

                }
                .pickerStyle(.segmented)
                .onChange(of: selectedType) { newValue in
                    if newValue != ScrribleType.write {
                        hasTypeValueChanged = true
                    }
                }
                Spacer()


            }
            .padding()

            Text(selectedType.explain)
                .font(.subheadline)

            HStack {
                Spacer()
                ScrribleVideoView(player: selectedType.video, selectedType: $selectedType, hasTypeValueChanged: $hasTypeValueChanged)
                Spacer()
            }
        }
    }
}

#Preview {
    ScrribleModalView(selectedType: .constant(ScrribleType.write), hasTypeValueChanged: .constant(false))
}

