//
//  File.swift
//  Blank
//
//  Created by Sup on 10/16/23.
//

import SwiftUI

struct File {
    var id: UUID
    var fileURL: URL
    var fileName: String
    var pages: [Page]
}
