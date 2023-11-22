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
    
    @Binding var movedCount: Int
    
    init(zoomScale: Binding<CGFloat>, movedCount: Binding<Int> = .constant(0), @ViewBuilder content: @escaping () -> Content) {
        self._zoomScale = zoomScale
        self.content = content
        self._movedCount = movedCount
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
        // 스크롤뷰의 감속 속도를 빠르게
        scrollView.decelerationRate = .fast
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor.systemGray4
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(zoomScale: $zoomScale, hostingController: UIHostingController(rootView: self.content()), movedCountBinding: $movedCount)
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
        
        let movedCountBinding: Binding<Int>
        private var movedCount = 0
        
        init(zoomScale: Binding<CGFloat>, hostingController: UIHostingController<Content>, movedCountBinding: Binding<Int>) {
            self.zoomScale = zoomScale
            self.hostingController = hostingController
            self.movedCountBinding = movedCountBinding
        }
        
        private func incrementMoveCount() {
            if movedCount == .max {
                movedCount = -1
            }
            
            movedCount += 1
            movedCountBinding.wrappedValue = movedCount
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.zoomScale.wrappedValue = scrollView.zoomScale
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            incrementMoveCount()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            incrementMoveCount()
        }
        
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            incrementMoveCount()
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            incrementMoveCount()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            incrementMoveCount()
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            incrementMoveCount()
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            incrementMoveCount()
        }
    }
}
