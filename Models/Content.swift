import Foundation
import AVFAudio
import SwiftUI
import FMDB

class Content: Identifiable, Hashable, ObservableObject {
    
    var id: Int = 0
    @Published var name: String = ""
    @Published var urlImage: String = ""
    @Published var urlMedia: String = ""
    @Published var contentType: Int = 15
    @Published var boardId: Int = -1
    @Published var row: Int = -1
    @Published var column: Int = -1
    @Published var userId: Int = -1
    @Published var childBoardLink: Int = 0
    @Published var childBoardId: Int = 0
    @Published var totalUses: Int = 0
    @Published var sessionUses: Int = 0
    @Published var backgroundColor: Int = 0
    @Published var color: Int = 0
    @Published var fontSize: Int = 0
    @Published var zoom: Bool = false
    @Published var doNotAddToPhraseBar: Bool = false
    @Published var doNotZoomPics: Bool = false
    @Published var ttsSpeech: String = ""
    @Published var externalUrl: String = ""
    @Published var alternateTTS: String = ""
    @Published var createDate: String = ""
    @Published var updateDate: String = ""
    
    static func == (lhs: Content, rhs: Content) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
        }
    
    func getString(column: String, defaultValue: String = "") -> String {
        var result: String = defaultValue
        let s = DataWrapper.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.string(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }
    
    func getInt(column: String, defaultValue: Int = -1) -> Int {
        var result: Int = defaultValue
        let s = DataWrapper.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.long(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }
    
    func setId(_ id: Int) -> Content {
        self.id = id;
        self.name = getString(column: "content_name", defaultValue: "")
        self.urlImage = getString(column: "content_url", defaultValue: "")
        self.urlMedia = getString(column: "content_url2", defaultValue: "")
        self.contentType = getInt(column: "content_type", defaultValue: 15)
        self.boardId = getInt(column: "board_id", defaultValue: -1)
        self.row = getInt(column: "row_index", defaultValue: -1)
        self.column = getInt(column: "clm_index", defaultValue: -1)
        self.userId = getInt(column: "user_id", defaultValue: -1)
        self.childBoardLink = getInt(column: "child_board_link", defaultValue: 0)
        self.childBoardId = getInt(column: "child_board_id", defaultValue: 0)
        self.totalUses = getInt(column: "total_uses", defaultValue: 0)
        self.sessionUses = getInt(column: "session_uses", defaultValue: 0)
        self.backgroundColor = getInt(column: "background_color", defaultValue: 0)
        self.color = getInt(column: "foreground_color", defaultValue: 0)
        self.fontSize = getInt(column: "font_size", defaultValue: 0)
        self.zoom = getInt(column: "zoom", defaultValue: 0) == 1
        self.doNotAddToPhraseBar = getInt(column: "do_not_add_to_phrasebar", defaultValue: 0) == 1
        self.doNotZoomPics = getInt(column: "do_not_zoom_pics", defaultValue: 0) == 1
        self.ttsSpeech = getString(column: "tts_speech", defaultValue: "")
        self.externalUrl = getString(column: "external_url", defaultValue: "")
        self.alternateTTS = getString(column: "alternate_tts", defaultValue: "")
        self.updateDate = getString(column: "update_date", defaultValue: "")
        self.createDate = getString(column: "create_date", defaultValue: "")
        return self;
    }
}

