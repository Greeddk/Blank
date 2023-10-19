//
//  CurrentPageView.swift
//  Blank
//
//  Created by Greed on 10/18/23.
//

import SwiftUI

struct CurrentPageView: View {
    let image: UIImage?
    
    var body: some View {
        if let image = image {
            VStack {
                Spacer().frame(height: 10)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.height * 0.85)
            }
            .background(Color(.systemGray6))
        } else {
            Text("Error")
        }
    }
}

