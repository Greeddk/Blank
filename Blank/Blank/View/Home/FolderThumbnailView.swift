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
            VStack {
                Spacer().frame(height: 40)
                Image(isRoot ? "folderBackIcon" : "folderIcon")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.blue)
                    .frame(height: 140)
            }
            .frame(width: 120, height: 140)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            Spacer().frame(height: 30)
            VStack {
                if let folder, !isRoot {
                    Text("\(folder.fileName)")
                        .font(.title3)
                        .fontWeight(.bold)
                } else {
                    Text("이전으로")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    FolderThumbnailView(folder: DUMMY_FOLDER)
}

#Preview {
    HomeView()
}
