//
//  SelectFolderView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/19.
//

import SwiftUI

struct SelectFolderView: View {
    @StateObject private var viewModel = SelectFolderViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.directoryList, children: \.subfolder) { directory in
                Label(directory.fileName, systemImage: "folder.fill")
            }
            .onTapGesture {
                
            }
            .navigationTitle("이동할 폴더 선택")
        }
    }
}

#Preview {
    SelectFolderView()
}
