//
//  SelectFolderView.swift
//  Blank
//
//  Created by 윤범태 on 2023/11/19.
//

import SwiftUI

struct SelectFolderView: View {
    @Environment(\.dismiss) var dismiss
    var selectedFiles: [FileSystem] = []
    @StateObject private var viewModel = SelectFolderViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                OutlineGroup(viewModel.directoryList, children: \.subfolder) { directory in
                    ZStack {
                        Label(directory.fileName, systemImage: "folder.fill")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .background(viewModel.selectedFolder == directory ? .cyan.opacity(0.22) : .clear)
                            .onTapGesture {
                                viewModel.selectedFolder = directory
                            }
                    }
                }
            }
            .navigationTitle("이동할 폴더 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("이동") {
                        viewModel.moveFiles(elements: selectedFiles)
                        dismiss()
                    }
                    .disabled(viewModel.selectedFolder == nil)
                    .bold()
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SelectFolderView()
}
