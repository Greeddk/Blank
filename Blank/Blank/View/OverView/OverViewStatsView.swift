//
//  OverViewStatsView.swift
//  Blank
//
//  Created by Greed on 11/7/23.
//

import SwiftUI

struct OverViewStatsView: View {
    var width: CGFloat
    var height: CGFloat
    var zoomScale: CGFloat
    
    var body: some View {
        VStack(spacing: -1) {
            Triangle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: width/4 / zoomScale, height: width/4 / zoomScale)
            RoundedRectangle(cornerSize: CGSize(width: width / 8 / zoomScale, height: height / 8 / zoomScale))
                .fill(Color(UIColor.systemGray5))
                .frame(width: width / zoomScale, height: height / zoomScale)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}
