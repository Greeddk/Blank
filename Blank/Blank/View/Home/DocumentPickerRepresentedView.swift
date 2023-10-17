//
//  DocumentPickerRepresentedView.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/17.
//

import SwiftUI

/// UIDocumentPickerViewController를 SwiftUI에서 사용 가능하도록 래핑
struct DocumentPickerReperesentedView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDocumentPickerViewController
    typealias SelectedHandler = (URL) -> Void
    
    var pickerVC: UIDocumentPickerViewController
    var selectedHandler: SelectedHandler
    
    init(selectedHandler: @escaping SelectedHandler) {
        self.pickerVC = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .jpeg, .image, .gif, .png])
        self.selectedHandler = selectedHandler
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        pickerVC.allowsMultipleSelection = false
        pickerVC.modalPresentationStyle = .pageSheet
        return pickerVC
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(pickerVC, selectedHandler: selectedHandler)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var selectedHandler: SelectedHandler
        
        init(_ pickerVC: UIDocumentPickerViewController, selectedHandler: @escaping SelectedHandler) {
            self.selectedHandler = selectedHandler
            super.init()
            pickerVC.delegate = self
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            
            selectedHandler(url)
        }
    }
}

#Preview {
    DocumentPickerReperesentedView { url in
        
    }
}

