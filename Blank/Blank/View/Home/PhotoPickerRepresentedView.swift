//
//  PhotoPickerRepresentedView.swift
//  Blank
//
//  Created by 윤범태 on 2023/10/18.
//

import SwiftUI
import PhotosUI

/// PHPickerViewController를 SwiftUI에서 사용 가능하도록 래핑
struct PhotoPickerRepresentedView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    typealias SelectedHandler = ([UIImage]) -> Void
    
    var pickerVC: PHPickerViewController
    var selectedHandler: SelectedHandler
    
    init(selectedHandler: @escaping SelectedHandler) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.selection = .ordered
        config.filter = .images
        
        pickerVC = .init(configuration: config)
        
        self.selectedHandler = selectedHandler
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }
        
            print("PhotoLibrary request is authorized")
        }
        
        return pickerVC
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(pickerVC, selectedHandler: selectedHandler)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var selectedHandler: SelectedHandler
        var pickerVC: PHPickerViewController
        
        init(_ pickerVC: PHPickerViewController, selectedHandler: @escaping SelectedHandler) {
            self.selectedHandler = selectedHandler
            self.pickerVC = pickerVC
            super.init()
            pickerVC.delegate = self
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            pickerVC.dismiss(animated: true)
            
            // guard let itemProvider = results.first?.itemProvider,
            //       itemProvider.canLoadObject(ofClass: UIImage.self) else {
            //     print("Cannot Load Object")
            //     return
            // }
            // 
            // itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            //     guard let image = image as? UIImage else {
            //         print("Image data is nil")
            //         return
            //     }
            //     
            //     DispatchQueue.main.async {
            //         self.selectedHandler(image)
            //     }
            // }
            
            // 여러 이미지 가져오기
            let group = DispatchGroup()
            var images: [UIImage] = []
            var order: [String] = []
            var asyncDict: [String: UIImage] = [:]
            
            for result in results {
                print("result:", results)
                let id = result.assetIdentifier ?? UUID().uuidString
                order.append(id)
                
                group.enter() // 디스패치그룹 시작
                let provider = result.itemProvider
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        guard let updatedImage = image as? UIImage else {
                            group.leave() // 디스패치그룹 끝
                            return
                        }
                        
                        asyncDict[id] = updatedImage
                        group.leave() // 디스패치그룹 끝
                    }
                }
            }
            
            group.notify(queue: .main) {
                for id in order {
                    print("id:", id)
                    images.append(asyncDict[id]!)
                }
                
                self.selectedHandler(images)
            }
        }
    }
    
}

struct PhotoPickerRepresentedView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerRepresentedView { images in
            
        }
    }
}
