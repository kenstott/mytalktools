//
//  Sync.swift
//  test
//
//  Created by Kenneth Stott on 5/8/23.
//

import Foundation

struct SyncMergeInput: Decodable, Encodable, Convertable {
    var databaseImage: String
    var userName: String
    var uuid: String
    var boardID: String
}

struct SyncMergeResult: Decodable, Encodable, Convertable {
    var Exception: String?
    var DatabaseImage: [UInt8]
    var DatabasePath: String
    var DirectoryList: [FileListDirectory]
    var DatabaseImageData: NSData {
        get {
            return NSData(bytes: DatabaseImage, length: DatabaseImage.count);
        }
    }
}

struct SyncMergeResultParent: Decodable, Encodable, Convertable {
    var d: SyncMergeResult
}

