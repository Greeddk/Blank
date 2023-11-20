//
//  ZoomableContainer.swift
//  Blank
//
//  Created by Greed on 10/24/23.
//

import SwiftUI

struct ZoomableContainer<Content: View>: UIViewRepresentable {
    @Binding var zoomScale: CGFloat
    private var content: () -> Content
    
    init(zoomScale: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._zoomScale = zoomScale
        self.content = content
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor.systemGray4
        scrollView.addSubview(hostedView)
        
        // 두 손가락 이상만 팬제스처가 활성화되도록 함
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        
        return scrollView
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(zoomScale: $zoomScale, hostingController: UIHostingController(rootView: self.content()))
    }
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        uiView.zoomScale = zoomScale
        context.coordinator.hostingController.rootView = self.content()
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    // MARK: - Coordinator
    class Coordinator: NSObject, UIScrollViewDelegate {
        var zoomScale: Binding<CGFloat>
        var hostingController: UIHostingController<Content>
        
        init(zoomScale: Binding<CGFloat>, hostingController: UIHostingController<Content>) {
            self.zoomScale = zoomScale
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.zoomScale.wrappedValue = scrollView.zoomScale
        }
    }
}
