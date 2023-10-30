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
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)
                .padding()

            HStack(alignment: .center, spacing: 20) {
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
            }
            .padding()

            Text(selectedType.explain)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding()


            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                ScrribleVideoView(player: selectedType.video, selectedType: $selectedType, hasTypeValueChanged: $hasTypeValueChanged)
                    .padding()
            }
            .padding()
            Spacer()
        }
       
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                closeBtn
            }
        }

    }

    private var closeBtn: some View {
        Button {
            dismiss()
        } label: {
            Text("완료")
        }
    }
}

#Preview {
    ScrribleModalView(selectedType: .constant(ScrribleType.write), hasTypeValueChanged: .constant(false))
}
