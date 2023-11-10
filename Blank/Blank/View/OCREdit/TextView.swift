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
    var height: CGFloat
    var width: CGFloat
    var orinX: UUID

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            UITextViewRepresentable(text: $name, isFocused: $isFocused, width: width, height: height)
                .frame(width: width, height: height)
        }
        .border(isFocused ? Color.yellow : Color.blue, width: 1.5)
        .background(Color.white)
    }
}


struct UITextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    var width: CGFloat
    var height: CGFloat
    var fontScale: CGFloat = 1.9

    func makeUIView(context: UIViewRepresentableContext<UITextViewRepresentable>) -> UITextField {
        let textView = UITextField(frame: .zero)

        textView.textAlignment = .left
        textView.delegate = context.coordinator
        let minSize = min(width, height)
        textView.font = UIFont(name: "Avenir", size: (minSize/fontScale))
//        textView.adjustsFontForContentSizeCategory = true
//        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.adjustsFontSizeToFitWidth = true
        textView.autocapitalizationType = .none
//        textView.borderStyle = .none
//        textView.sizeToFit()
        textView.addLeftPadding(width: width)

        return textView
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
//        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        uiView.setContentCompressionResistancePriority(.required, for: .vertical)
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

extension UITextField {
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width / 6, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
