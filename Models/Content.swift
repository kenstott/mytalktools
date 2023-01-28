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

class ContentType {
    static var imageSoundNameLink = 12
    static var imageSoundLink = 9
    static var imageNameLink = 10
    static var imageLink = 6
    static var soundNameLink = 11
    static var soundLink = 7
    static var nameLink = 8
    static var link = 1
    static var imageSoundName = 15
    static var imageSound = 13
    static var imageName = 14
    static var image = 2
    static var soundName = 16
    static var sound = 3
    static var name = 4
    static var goHome = 19
    static var goBack = 18
}


class Content: Identifiable, Hashable, ObservableObject {
    
    func copy(id: Int) -> Content {
        let c = Content()
        c.id = id
        c.name = self.name
        c.imageURL = self.imageURL
        c.soundURL = self.soundURL
        c.contentType = self.contentType
        c.childBoardId = self.childBoardId
        c.childBoardLink = self.childBoardLink
        c.backgroundColor = self.backgroundColor
        c.color = self.color
        c.fontSize = self.fontSize
        c.zoom = self.zoom
        c.doNotAddToPhraseBar = self.doNotAddToPhraseBar
        c.doNotZoomPics = self.doNotZoomPics
        c.ttsSpeech = self.ttsSpeech
        c.externalUrl = self.externalUrl
        c.alternateTTS = self.alternateTTS
        c.alternateTTSVoice = self.alternateTTSVoice
        c.negate = self.negate
        c.positive = self.positive
        c.repeatBoard = self.repeatBoard
        c.repeatChildBoards = self.repeatChildBoards
        c.popupStyleChildBoard = self.popupStyleChildBoard
        c.hidden = self.hidden
        c.ttsSpeechPrompt = self.ttsSpeechPrompt
        c.cellSize = self.cellSize
        return c
    }
    
    
    private func NilOrEmpty(_ s: String?) -> Bool { return s == nil || s == "" }
    
    var id: Int = 0
    @Published var name: String = ""
    @Published var imageURL: String = ""
    @Published var soundURL: String = ""
    @Published var contentType: Int = 15
    @Published var boardId: Int = -1
    @Published var row: Int = -1
    @Published var column: Int = -1
    @Published var userId: Int = -1
    @Published var childBoardLink: UInt = 0
    @Published var childBoardId: UInt = 0
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
    
    var image: UIImage {
        get {
            switch contentType {
                case ContentType.goHome: return UIImage(systemName: "house")!
                case ContentType.goBack: return UIImage(systemName: "arrowshape.backward")!
                default: return Media.getImage(imageURL)
            }
        }
    }
    
    // Legacy - MyTalk
    var cellType: Int {
        get {
            if (self.contentType != ContentType.goHome && self.contentType != ContentType.goBack) {
                if (self.link != 0) {
                    if (!NilOrEmpty(imageURL)) {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.imageSoundNameLink; // A + I + S + T
                            }
                            else {
                                return ContentType.imageSoundLink; // A + I + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.imageNameLink; // A + I + T
                            }
                            else {
                                return ContentType.imageLink; // A + I
                            }
                        }
                    }
                    else {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.soundNameLink; // A + S + T
                            }
                            else {
                                return ContentType.soundLink; // A + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.nameLink; // A + T
                            }
                            else {
                                return ContentType.link; // A
                            }
                        }
                    }
                }
                else {
                    if (!NilOrEmpty(imageURL)) {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.imageSoundName; // I + S + T
                            }
                            else {
                                return ContentType.imageSound; // I + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.imageName; // I + T
                            }
                            else {
                                return ContentType.image; // I
                            }
                        }
                    }
                    else {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return ContentType.soundName; // S + T
                            }
                            else {
                                return ContentType.sound; // S
                            }
                        }
                        else {
                            if (self.name.count > 0) {
                                return ContentType.name; // T
                            }
                            else {
                                // nothing ???
                            }
                        }
                    }
                }
            }
            return self.contentType;
        }
    }
    
    var link: UInt {
        get {
            if (childBoardLink != 0) {
                return UInt(truncatingIfNeeded: self.childBoardLink)
            }
            return UInt(truncatingIfNeeded: self.childBoardId)
        }
    }
    
    var linkId: UInt {
        get {
            return UInt(self.link)
        }
    }
    
    static func == (lhs: Content, rhs: Content) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }
        guard lhs.imageURL == rhs.imageURL else {
            return false
        }
        guard lhs.soundURL == rhs.soundURL else {
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
        hasher.combine(imageURL)
        hasher.combine(soundURL)
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
        let s = BoardState.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.string(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }
    
    func getInt(column: String, defaultValue: Int = -1) -> Int {
        var result: Int = defaultValue
        let s = BoardState.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.long(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }
    
    func getUInt(column: String, defaultValue: UInt = 0) -> UInt {
        var result: UInt = defaultValue
        let s = BoardState.db!.executeQuery("SELECT \(column) FROM content WHERE iphone_content_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = UInt(s?.unsignedLongLongInt(forColumnIndex: 0) ?? UInt64(defaultValue))
        }
        s?.close()
        return result
    }
    
    func setId(_ id: Int) -> Content {
        self.id = id;
        self.name = getString(column: "content_name", defaultValue: "")
        self.imageURL = getString(column: "content_url", defaultValue: "")
        self.soundURL = getString(column: "content_url2", defaultValue: "")
        self.contentType = getInt(column: "content_type", defaultValue: 15)
        self.boardId = getInt(column: "board_id", defaultValue: -1)
        self.row = getInt(column: "row_index", defaultValue: -1)
        self.column = getInt(column: "clm_index", defaultValue: -1)
        self.userId = getInt(column: "user_id", defaultValue: -1)
        self.childBoardLink = getUInt(column: "child_board_link", defaultValue: 0)
        self.childBoardId = getUInt(column: "child_board_id", defaultValue: 0)
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
        self.imageURL = "Snack_reduced.png"
        self.soundURL = "Snack.mp3"
        return self;
    }
    
    func voice(_ speak: Speak, ttsVoice: String, ttsVoiceAlternate: String, speechRate: Double, voiceShape: Double, callback: @escaping () -> Void) {
        if (soundURL != "") {
            let soundFileURL = Media.getURL(soundURL)
            do {
                if (soundFileURL != nil) {
                    speak.setAudioPlayer(try AVAudioPlayer(contentsOf: soundFileURL!)) {
                        callback()
                    }
                    speak.play()
                }
            }
            catch {
                print("Problem playing: \(soundFileURL!)")
            }
        }
        else  {
            speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                callback()
            }
            let phrase = alternateTTS != "" ? alternateTTS : name
            var alternate: Bool? = alternateTTSVoice
            speak.utter(phrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate)
        }
    }
    
    
}

