//
//  NewDatabase.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

func matchStrings(input: String, pattern: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: pattern)
        let nsInput = input as NSString
        let matches = regex.matches(in: input, range: NSRange(location: 0, length: nsInput.length))
        return matches.map { nsInput.substring(with: $0.range)}
    } catch {
        return []
    }
}

func fixDate(date: String) -> Date {
    let result = matchStrings(input: date, pattern: "[0-9]+")
    if (result.count > 0) {
        return Date(timeIntervalSince1970: (Double(result[0]) ?? 0) / 1000.0 )
    }
    return Date.now
}

struct FileListDirectory: Decodable, Encodable {
    var Name: String
    var FileList: [DocumentFileInfo]
}

struct DocumentFileInfoArray: Decodable, Encodable {
    var d: [DocumentFileInfo]
}

struct DocumentFileInfo: Decodable, Encodable {
    var __type: String
    var CreationTime: String
    var CreationTimeUtc: String
    var LastAccessTime: String
    var LastAccessTimeUtc: String
    var LastWriteTime: String
    var LastWriteTimeUtc: String
    var lastWriteTimeUtc: Date {
        get {
            return fixDate(date: LastWriteTimeUtc)
        }
    }
    var IsReadOnly: Bool
    var Extension: String
    var Fullname: String
    var Name: String
    var Length: Int
    var HashCode: Int
}
struct NewDatabaseResult: Decodable, Encodable {
    var __type: String
    var DatabaseImage: [UInt8]
    var DatabasePath: String
    var DirectoryList: [FileListDirectory]
    var DatabaseImageData: NSData {
        get {
            return NSData(bytes: DatabaseImage, length: DatabaseImage.count);
        }
    }
}

struct NewDatabase: Decodable, Encodable {
    var d: NewDatabaseResult
}

struct NewDatabaseInput: Decodable, Encodable {
    var userName: String
    var uuid: String = ""
    var boardID: String?
}
