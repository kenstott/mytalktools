import Foundation
import AVFAudio
import SwiftUI
import FMDB

class ForegroundColorMask
{
    static var kfBlack = 1
    static var kfDarkGray = 2
    static var kfLightGray = 3
    static var kfWhite = 4
    static var kfGray = 5
    static var kfPink = 6
    static var kfGreen = 7
    static var kfBlue = 8
    static var kfCyan = 9
    static var kfYellow = 10
    static var kfMagenta = 11
    static var kfOrange = 12
    static var kfPurple = 13
    static var kfBrown = 14
    static var kfClear = 15
    static var kfRed = 16
    static var kHidden = 0x0001 << 8
    static var kNegate = 0x0001 << 9
    static var kNoRepeatsOnChildren = 0x0001 << 10
    static var kNoRepeats = 0x0001 << 11
    static var kPositive = 0x0001 << 12
    static var kAlternateTTSVoice = 0x0001 << 13
    static var kPopupStyleChildBoard = 0x0001 << 14
};


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
    @Published var alternateTTSVoice: Bool = false
    @Published var negate: Bool = false
    @Published var positive: Bool = false
    @Published var repeatBoard: Bool = false
    @Published var repeatChildBoards: Bool = false
    @Published var popupStyleChildBoard: Bool = false
    @Published var hidden: Bool = false
    @Published var ttsSpeechPrompt: String = ""
    @Published var createDate: String = ""
    @Published var updateDate: String = ""
    @Published var cellSize = 1
    var link: UInt16 {
        get {
            if (childBoardLink != 0) {
                return UInt16(self.childBoardLink)
            }
            return UInt16(self.childBoardId)
        }
    }
    
    static func == (lhs: Content, rhs: Content) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        guard lhs.urlImage == rhs.urlImage else {
            return false
        }
        guard lhs.urlMedia == rhs.urlMedia else {
            return false
        }
        guard lhs.ttsSpeech == rhs.ttsSpeech else {
            return false
        }
        guard lhs.externalUrl == rhs.externalUrl else {
            return false
        }
        guard lhs.alternateTTS == rhs.alternateTTS else {
            return false
        }
        guard lhs.childBoardId == rhs.childBoardId else {
            return false
        }
        guard lhs.childBoardLink == rhs.childBoardLink else {
            return false
        }
        guard lhs.color == rhs.color else {
            return false
        }
        guard lhs.fontSize == rhs.fontSize else {
            return false
        }
        guard lhs.zoom == rhs.zoom else {
            return false
        }
        guard lhs.doNotZoomPics == rhs.doNotZoomPics else {
            return false
        }
        guard lhs.doNotAddToPhraseBar == rhs.doNotAddToPhraseBar else {
            return false
        }
        guard lhs.row == rhs.row else {
            return false
        }
        guard lhs.column == rhs.column else {
            return false
        }
        guard lhs.ttsSpeechPrompt == rhs.ttsSpeechPrompt else {
            return false
        }
        guard lhs.alternateTTSVoice == rhs.alternateTTSVoice else {
            return false
        }
        guard lhs.negate == rhs.negate else {
            return false
        }
        guard lhs.positive == rhs.positive else {
            return false
        }
        guard lhs.repeatBoard == rhs.repeatBoard else {
            return false
        }
        guard lhs.repeatChildBoards == rhs.repeatChildBoards else {
            return false
        }
        guard lhs.hidden == rhs.hidden else {
            return false
        }
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(urlImage)
        hasher.combine(urlMedia)
        hasher.combine(ttsSpeech)
        hasher.combine(externalUrl)
        hasher.combine(alternateTTS)
        hasher.combine(childBoardId)
        hasher.combine(childBoardLink)
        hasher.combine(color)
        hasher.combine(fontSize)
        hasher.combine(zoom)
        hasher.combine(doNotZoomPics)
        hasher.combine(doNotAddToPhraseBar)
        hasher.combine(row)
        hasher.combine(column)
        hasher.combine(ttsSpeechPrompt)
    }
    
    func getString(column: String, defaultValue: String = "") -> String {
        var result: String = defaultValue
        let s = GlobalState.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.string(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }
    
    func getInt(column: String, defaultValue: Int = -1) -> Int {
        var result: Int = defaultValue
        let s = GlobalState.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
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
        self.ttsSpeechPrompt = getString(column: "tts_speech", defaultValue: "")
        self.updateDate = getString(column: "update_date", defaultValue: "")
        self.createDate = getString(column: "create_date", defaultValue: "")
        self.negate = (self.color & ForegroundColorMask.kNegate) != 0
        self.alternateTTSVoice = (self.color & ForegroundColorMask.kAlternateTTSVoice) != 0
        self.positive = (self.color & ForegroundColorMask.kPositive) != 0
        self.repeatBoard = (self.color & ForegroundColorMask.kNoRepeats) == 0
        self.repeatChildBoards = (self.color & ForegroundColorMask.kNoRepeatsOnChildren) == 0
        self.popupStyleChildBoard = (self.color & ForegroundColorMask.kPopupStyleChildBoard) != 0
        self.hidden = (self.color & ForegroundColorMask.kHidden) != 0
        return self;
    }
    
    func setPreview() -> Content {
        self.name = "Snack"
        self.urlImage = "Snack_reduced.png"
        self.urlMedia = "Snack.mp3"
        return self;
    }
}

