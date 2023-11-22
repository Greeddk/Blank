//
//  FolderThumbnailView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/16.
//

import SwiftUI

struct FolderThumbnailView: View {
    var folder: Folder?
    var isRoot: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: isRoot ? "chevron.backward.square.fill" : "folder.fill")
                    .resizable()
                    .foregroundStyle(.blue)
                    .frame(width: 100, height: 100)
            }
            .frame(width: 200, height: 200)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            Spacer().frame(height: 15)
            
            if let folder, !isRoot {
                Text("\(folder.fileName)")
                    .font(.title2)
                    .fontWeight(.bold)
            } else {
                Text("...")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    FolderThumbnailView(folder: DUMMY_FOLDER)
}
