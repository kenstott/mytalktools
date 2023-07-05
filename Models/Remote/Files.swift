//
//  User.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

struct DocumentFileListInput: Encodable {
    var userName: String
    var libraryName: String
    var searchPattern: String
}

class Files: Identifiable, ObservableObject {
    static var getFiles = Network<DocumentFileInfoArray, DocumentFileListInput>(service: "GetDocumentFileList")
}
