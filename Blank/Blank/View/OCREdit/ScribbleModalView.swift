//
//  ScrribleModalView.swift
//  Blank
//
//  Created by 조용현 on 10/22/23.
//

import SwiftUI
import AVKit

struct ScribbleModalView: View {
    @Environment(\.dismiss) var dismiss
    @State var text: String = ""
    @ObservedObject var playerViewModel: PlayerViewModel = PlayerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("손글씨 입력 쓰기")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)
                    .padding()

                HStack(alignment: .center, spacing: 20) {
                    Picker("타입", selection: $playerViewModel.selectedType) {
                        ForEach(ScribbleType.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: playerViewModel.selectedType) { newValue in
                        if newValue != ScribbleType.write {
                            playerViewModel.hasTypeValueChanged = true
                        }
                    }
                }
                .padding()

                Text(playerViewModel.selectedType.explain)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding()


                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    ScribbleVideoView(playerViewModel: playerViewModel)
                        .padding()
                }
                .padding()

                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    TextField(playerViewModel.selectedType.text.0, text: $text)
                        .frame(width: 600)
                        .font(.system(size: 25))
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .onAppear() {
                            text = playerViewModel.selectedType.text.1
                        }

                        .onChange(of: playerViewModel.selectedType) { newValue in
                            text = playerViewModel.selectedType.text.1
                        }
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeBtn
                }
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

<<<<<<< HEAD:Blank/Blank/View/OCREdit/ScrribleModalView.swift
#Preview {
    ScrribleModalView()
}
=======
//#Preview {
//    ScribbleModalView(selectedType: .constant(ScribbleType.write), hasTypeValueChanged: .constant(false))
//}
>>>>>>> 96-bug-moalview-bug-fix:Blank/Blank/View/OCREdit/ScribbleModalView.swift
