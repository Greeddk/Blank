//
//  TextView.swift
//  Blank
//
//  Created by 조용현 on 10/23/23.
//

import SwiftUI

struct TextView: View {
    @State var isFocused: Bool = false
    @Binding var name: String
    @Binding var height: CGFloat
    @Binding var width: CGFloat
    @Binding var scale: CGFloat
    @Binding var orinX: UUID

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            UITextViewRepresentable(text: $name, isFocused: $isFocused, height: $height)
                .frame(width: width, height: height)
        }
        .border(isFocused ? Color.yellow : Color.blue, width: 1.5)
        .background(Color.white)
    }
}


struct UITextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var height: CGFloat
    var fontSize: CGFloat = 1.9

    func makeUIView(context: UIViewRepresentableContext<UITextViewRepresentable>) -> UITextField {
        let textView = UITextField(frame: .zero)

        textView.textAlignment = .center
        textView.delegate = context.coordinator
        textView.font = UIFont(name: "Avenir", size: (height/fontSize))
        textView.textAlignment = .center
//        textView.adjustsFontForContentSizeCategory = true
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.adjustsFontSizeToFitWidth = true
        textView.autocapitalizationType = .none
        textView.borderStyle = .none


        textView.font = UIFont(name: "Avenir", size: height/1.9)
        textView.sizeToFit()

        return textView
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func makeCoordinator() -> UITextViewRepresentable.Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UITextViewRepresentable

        init(_ parent: UITextViewRepresentable) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
             parent.text = textField.text ?? ""
         }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }
     }
}
