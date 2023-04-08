//
//  Library.swift
//  test
//
//  Created by Kenneth Stott on 3/5/23.
//

import Foundation

struct LibraryWebBoard: Decodable, Encodable {
    var dollarSignId: String
    var BoardId: UInt
    var Columns: Int = 0
    var Rows: Int = 0
    var Sort1: Int = 0
    var Sort2: Int = 0
    var Sort3: Int = 0
}

struct LibraryBoardContent: Decodable, Encodable {
    var WebContentId: Int = 0
    var contentName: String
    var contentUrl: String
    var contentUrl2: String
    var contentThumbnailUrl: String
    var contentType: Int
    var UpdateDate: String
    var RowIndex: UInt
    var ClmIndex: UInt
    var ChildBoardId: UInt
    var ChildBoardLinkId: UInt
    var TotalUses: UInt
    var SessionUses: UInt
    var Background: UInt
    var Foreground: UInt
    var FontSize: UInt
    var Zoom: UInt
    var DoNotAddToPhraseBar: UInt
    var DoNotZoomPics: UInt
    var TtsSpeechPrompt: String
    var ExternalUrl: String
    var AlternateTtsText: String
    var HotSpotStyle: Bool
}

struct LibraryBoard: Decodable, Encodable {
    var IphoneBoardId: UInt
    var WebBoardId: UInt
    var ServerTime: String
    var WebBoard: LibraryWebBoard
    var Contents: [LibraryBoardContent]
}

struct LibraryContent: Decodable, Encodable, Hashable {
    var Text: String = ""
    var ContentId: Int = 0
    var ChildBoardLinkId: UInt = 0
    var ChildBoardId: UInt = 0
    var Picture: String? = ""
    var Sound: String? = ""
    var DoNotAddToPhraseBar: Bool = false
    var DoNotZoomPics: Bool = false
    var Zoom: Bool = false
    var ToHome: Bool = false
    var Back: Bool = false
    var Version: String? = ""
    var HotSpotStyle: Bool = false
    var Background: Int = 0
    var Foreground: Int = 0
    var FontSize: Int = 0
    var AlternateTtsText: String = ""
    var ExternalUrl: String = ""
    var TtsSpeechPrompt: String = ""
    var ChildBoardColumnCount: Int = 0
}
struct LibraryItem: Decodable, Encodable, Hashable {
    var OriginalFilename: String
    var CompressedFilename: String
    var FilenameUnescaped: String
    var ItemType: Int
    var LibraryItemId: Int
    var LibraryItemIdDiscriminator: Int
    var Path: String
    var Tags: [String]
    var Tags0: String
    var Tags1: String
    var Tags3: String
    var Tags4: String
    var TagString: String
    var ThumbnailUrl: String?
    var MediaUrl: String?
    var Content: LibraryContent?
}

struct GetLibraryInput: Decodable, Encodable, Convertable {
    var libraryId: Int
}

struct Rights: Decodable, Encodable {
    var create: Bool
    var read: Bool
    var update: Bool
    var delete: Bool
}

let UserUploadUrl = "https://mytalktools.com/dnn/UserUploads/"

class Library: Identifiable, ObservableObject {
    
    static var cache: Dictionary<Int, Array<LibraryItem>> = [:]
    static func cleanseFilename(_ filename: String) -> String {
        var x = filename;
        x = x
            .replacing("%20", with: " ")
            .replacing(".png", with: "")
            .replacing(".jpg", with: "")
            .replacing(".mp3", with: "")
            .replacing(".mp4", with: "")
            .replacing("_", with: " ")
        let pattern = "\\d{2,}$"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let modText = regex.stringByReplacingMatches(in: x, options: [], range: NSRange(location: 0, length: x.count), withTemplate: "")
        return modText
    }
    
    var getLibraryItemsPost = GetPost<Array<LibraryItem>, GetLibraryInput>(service: "GetLibraryItems")
    
    @Published var items: [LibraryItem]?
    @Published var root: LibraryRoot?
    @Published var rights: Rights = Rights(create: false, read: false, update: false, delete: false)
    @Published var loaded = false
    
    init(_ root: LibraryRoot, username: String) {
        self.root = root
        self.rights = getLibraryRights(username)
    }
    
    public func getLibraryRights(_ username: String) -> Rights {
        if (root?.OwnerId == username) {
            return Rights(create: true, read: true, update: true, delete: true)
        }
        let userRights = root?.SharedUsers?.filter { user in username == user.UserNameorInviteEmail } ?? []
        if userRights.count == 0 {
            return Rights(create: false, read: false, update: false, delete: false)
        }
        return Rights(create: userRights[0].Create, read: userRights[0].Update, update: userRights[0].Update, delete: userRights[0].Delete)
    }
    
    public func getLibraryItems() {
        if Library.cache[self.root?.LibraryId ?? 0] != nil {
            items = Library.cache[self.root?.LibraryId ?? 0]
            loaded = true
        } else {
            Task {
                do {
                    let result = try await getLibraryItemsPost.execute(params: GetLibraryInput(libraryId: root?.LibraryId ?? 0))
                    DispatchQueue.main.async {
                        self.items = (result ?? [])
                            .map {
                                var row = $0
                                
                                row.MediaUrl = "\(UserUploadUrl)\((row.Path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "").replacing("%2F", with: "/").replacing("%2E", with: "."))\(row.OriginalFilename)"
                                if row.ItemType == 2 {
                                    row.ThumbnailUrl = "\(UserUploadUrl)\((row.Path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "").replacing("%2F", with: "/").replacing("%2E", with: "."))\(row.CompressedFilename)"
                                } else {
                                    print(row.ItemType, row.OriginalFilename)
                                }
                                if row.ItemType == 3 {
                                    let PictureUrl = "\(UserUploadUrl)\(row.Path.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")\(((row.Content?.Picture ?? "").addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "").replacing("%2F", with: "/").replacing("%2E", with: "."))"
                                    row.Content?.Picture = PictureUrl
                                }
                                return row
                            }
                            .sorted { $0.OriginalFilename < $1.OriginalFilename }
                        Library.cache[self.root?.LibraryId ?? 0] = self.items!
                        self.loaded = true
                    }
                } catch let error {
                    print(error)
                }
            }
        }
    }
}
