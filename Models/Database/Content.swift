import Foundation
import AVFAudio
import SwiftUI
import FMDB

enum ContentType: Int, CaseIterable, Identifiable {
    var id: Self { self }
    
    case imageSoundNameLink = 12
    case imageSoundLink = 9
    case imageNameLink = 10
    case imageLink = 6
    case soundNameLink = 11
    case soundLink = 7
    case nameLink = 8
    case link = 1
    case imageSoundName = 15
    case imageSound = 13
    case imageName = 14
    case image = 2
    case soundName = 16
    case sound = 3
    case name = 4
    case goHome = 18
    case goBack = 19
}

class Content: Identifiable, Hashable, ObservableObject {
    
    enum BackgroundColorMask: Int {
        case kNone = 0
        case kTop = 256
        case kBottom = 512
        case kRight = 1024
        case kLeft = 2048
        case kOverlay = 4096
        case kOpaque = 8192
    }
    
    enum ForegroundColorMask: Int
    {
        case kfDefault = 0
        case kfBlack = 1
        case kfDarkGray = 2
        case kfLightGray = 3
        case kfWhite = 4
        case kfGray = 5
        case kfPink = 6
        case kfGreen = 7
        case kfBlue = 8
        case kfCyan = 9
        case kfYellow = 10
        case kfMagenta = 11
        case kfOrange = 12
        case kfPurple = 13
        case kfBrown = 14
        case kfClear = 15
        case kfRed = 16
        case kHidden = 256
        case kNegate = 512
        case kNoRepeatsOnChildren = 1024
        case kNoRepeats = 2048
        case kPositive = 4096
        case kAlternateTTSVoice = 8192
        case kPopupStyleChildBoard = 16384
    };
    
    static func convertColor(value: Int) -> Color? {
        switch(ForegroundColorMask(rawValue: value) ?? ForegroundColorMask.kfDefault) {
        case .kfWhite: return Color.white
        case .kfRed: return Color.red
        case .kfBlue: return Color.blue
        case .kfCyan: return Color.cyan
        case .kfGray: return Color.gray
        case .kfPink: return Color.pink
        case .kfBlack: return Color.black
        case .kfBrown: return Color.brown
        case .kfClear: return Color.white.opacity(1.0)
        case .kfOrange: return Color.orange
        case .kfPurple: return Color.purple
        case .kfMagenta: return Color(red: 1.0, green: 0.0, blue: 1.0)
        case .kfYellow: return Color.yellow
        case .kfDarkGray: return Color(red: 0.66, green: 0.66, blue: 0.66)
        case .kfLightGray: return Color(red: 0.82, green: 0.82, blue: 0.82)
        default: return nil
        }
    }
    
    func copy(id: Int) -> Content {
        let c = Content()
        c.id = id
        c.name = self.name
        c.imageURL = self.imageURL
        c.soundURL = self.soundURL
        c.contentType = self.contentType
        c.childBoardId = self.childBoardId
        c.childBoardLink = self.childBoardLink
        c.background = self.background
        c.backgroundColor = self.backgroundColor
        c.color = self.color
        c.foregroundColor = self.foregroundColor
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
        c.isOpaque = self.isOpaque
        c.isRepeatBoard = self.isRepeatBoard
        c.isRepeatRowTop = self.isRepeatRowTop
        c.isRepeatedCellOverlay = self.isRepeatedCellOverlay
        c.isRepeatChildBoards = self.isRepeatChildBoards
        c.isRepeatRowBottom = self.isRepeatRowBottom
        c.isRepeatColumnLeft = self.isRepeatColumnLeft
        c.isRepeatColumnRight = self.isRepeatColumnRight
        c.column = self.column
        c.row = self.row
        return c
    }
    
    func save() -> Void {
        setColumn(column: "content_name", value: self.name)
        setColumn(column: "content_url", value: self.imageURL)
        setColumn(column: "content_url2", value: self.soundURL)
        setColumn(column: "content_type", value: self.contentType.rawValue)
        setColumn(column: "row_index", value: self.row)
        setColumn(column: "clm_index", value: self.column)
        setColumn(column: "child_board_link", value: childBoardLink)
        setColumn(column: "child_board_id", value: self.childBoardId)
        setColumn(column: "background_color", value: self.background)
        setColumn(column: "foreground_color", value: self.color)
        setColumn(column: "font_size", value: self.fontSize)
        setColumn(column: "zoom", value: self.zoom)
        setColumn(column: "do_not_add_to_phrasebar", value: self.doNotAddToPhraseBar)
        setColumn(column: "do_not_zoom_pics", value: self.doNotZoomPics)
        setColumn(column: "tts_speech", value: self.ttsSpeech)
        setColumn(column: "external_url", value: self.externalUrl)
        setColumn(column: "alternate_tts", value: self.alternateTTS)
        setColumn(column: "tts_speech", value: self.ttsSpeechPrompt)
        setColumn(column: "update_date", value: ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: "T", with: " "))
    }
    
    private func NilOrEmpty(_ s: String?) -> Bool { return s == nil || s == "" }
    
    private func getRepeat(value: Int) -> Int {
        return value & 0xFF00;
    }
    
    var id: Int = 0
    private var background: Int = 0
    private var color: Int = 0
    @Published var name: String = ""
    @Published var imageURL: String = ""
    @Published var soundURL: String = ""
    @Published var contentType: ContentType = ContentType.imageSoundName
    @Published var boardId: Int = -1
    @Published var row: Int = -1
    @Published var column: Int = -1
    @Published var userId: Int = -1
    @Published var childBoardLink: UInt = 0
    @Published var childBoardId: UInt = 0
    @Published var totalUses: Int = 0
    @Published var sessionUses: Int = 0
    @Published var foregroundColor: Int = 0
    @Published var backgroundColor: Int = 0
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
    @Published var isRepeatRowTop: Bool = false
    @Published var isRepeatRowBottom: Bool = false
    @Published var isRepeatColumnRight: Bool = false
    @Published var isRepeatColumnLeft: Bool = false
    @Published var isRepeatedCellOverlay: Bool = false
    @Published var isOpaque: Bool = false
    @Published var isRepeatBoard: Bool = false
    @Published var isRepeatChildBoards: Bool = false
    
    var isVideo: Bool {
        get {
            return soundURL.lowercased().contains("\\.(mov|avi|mp4|mpeg4|wmv|m4v)")
        }
    }
    
    func isVideo(soundURL: String) -> Bool {
        
        return soundURL.lowercased().contains("\\.(mov|avi|mp4|mpeg4|wmv|m4v)")
        
    }
    
    var image: UIImage {
        get {
            switch contentType {
            case .goHome: return UIImage(systemName: "house")!
            case .goBack: return UIImage(systemName: "arrowshape.backward")!
            default: return Media.getImage(imageURL)
            }
        }
    }
    
    // Legacy - MyTalk
    var cellType: ContentType {
        get {
            if (self.contentType != .goHome && self.contentType != .goBack) {
                if (self.link != 0) {
                    if (!NilOrEmpty(imageURL)) {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return .imageSoundNameLink; // A + I + S + T
                            }
                            else {
                                return .imageSoundLink; // A + I + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return .imageNameLink; // A + I + T
                            }
                            else {
                                return .imageLink; // A + I
                            }
                        }
                    }
                    else {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return .soundNameLink; // A + S + T
                            }
                            else {
                                return .soundLink; // A + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return .nameLink; // A + T
                            }
                            else {
                                return .link; // A
                            }
                        }
                    }
                }
                else {
                    if (!NilOrEmpty(imageURL)) {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return .imageSoundName; // I + S + T
                            }
                            else {
                                return .imageSound; // I + S
                            }
                        }
                        else {
                            if (!NilOrEmpty(self.name)) {
                                return .imageName; // I + T
                            }
                            else {
                                return .image; // I
                            }
                        }
                    }
                    else {
                        if (!NilOrEmpty(soundURL)) {
                            if (!NilOrEmpty(self.name)) {
                                return .soundName; // S + T
                            }
                            else {
                                return .sound; // S
                            }
                        }
                        else {
                            if (self.name.count > 0) {
                                return .name; // T
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
    
    func setColumn(column: String, value: Any) -> Void {
        BoardState.db!.executeUpdate("UPDATE content set \(column) = ? WHERE iphone_content_id = ?", withArgumentsIn: [value,id]);
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
        self.contentType = ContentType(rawValue: getInt(column: "content_type", defaultValue: 15)) ?? .imageSoundName
        self.boardId = getInt(column: "board_id", defaultValue: -1)
        self.row = getInt(column: "row_index", defaultValue: -1)
        self.column = getInt(column: "clm_index", defaultValue: -1)
        self.userId = getInt(column: "user_id", defaultValue: -1)
        self.childBoardLink = getUInt(column: "child_board_link", defaultValue: 0)
        self.childBoardId = getUInt(column: "child_board_id", defaultValue: 0)
        self.totalUses = getInt(column: "total_uses", defaultValue: 0)
        self.sessionUses = getInt(column: "session_uses", defaultValue: 0)
        self.background = getInt(column: "background_color", defaultValue: 0)
        self.color = getInt(column: "foreground_color", defaultValue: 0)
        self.foregroundColor = self.color & 0x00FF
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
        self.negate = (self.color & ForegroundColorMask.kNegate.rawValue) != 0
        self.alternateTTSVoice = (self.color & ForegroundColorMask.kAlternateTTSVoice.rawValue) != 0
        self.positive = (self.color & ForegroundColorMask.kPositive.rawValue) != 0
        self.repeatBoard = (self.color & ForegroundColorMask.kNoRepeats.rawValue) == 0
        self.repeatChildBoards = (self.color & ForegroundColorMask.kNoRepeatsOnChildren.rawValue) == 0
        self.popupStyleChildBoard = (self.color & ForegroundColorMask.kPopupStyleChildBoard.rawValue) != 0
        self.hidden = (self.color & ForegroundColorMask.kHidden.rawValue) != 0
        self.isRepeatBoard = (self.color & ForegroundColorMask.kNoRepeats.rawValue) == 0
        self.isRepeatChildBoards = (self.color & ForegroundColorMask.kNoRepeatsOnChildren.rawValue) == 0
        setAllRepeats()
        return self;
    }
    
    func setAllRepeats() -> Void {
        self.isRepeatRowTop = getRepeat(value: self.background) == BackgroundColorMask.kTop.rawValue
        self.isRepeatRowBottom = getRepeat(value: self.background) == BackgroundColorMask.kBottom.rawValue
        self.isRepeatColumnRight = getRepeat(value: self.background) == BackgroundColorMask.kRight.rawValue
        self.isRepeatColumnLeft = getRepeat(value: self.background) == BackgroundColorMask.kLeft.rawValue
        self.isRepeatedCellOverlay = getRepeat(value: self.background) == BackgroundColorMask.kOverlay.rawValue
        self.isOpaque = getRepeat(value: self.background) == BackgroundColorMask.kOpaque.rawValue
        self.backgroundColor = self.background & 0x00FF
    }
    
    func setRepeat(value: BackgroundColorMask) ->Void {
        background = (background & 0x00FF) | value.rawValue
        setAllRepeats()
    }
    
    func setOpaque(value: Bool) -> Void {
        backgroundColor = value ? backgroundColor | BackgroundColorMask.kOpaque.rawValue : backgroundColor & ~BackgroundColorMask.kOpaque.rawValue
        setAllRepeats()
    }
    
    func setNegate(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kNegate.rawValue : color & ~ForegroundColorMask.kNegate.rawValue
        self.foregroundColor = self.color & 0x00FF
        if (value) {
            color = color & ~ForegroundColorMask.kPositive.rawValue
        }
        negate = value
    }
    
    func setPositive(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kPositive.rawValue : color & ~ForegroundColorMask.kPositive.rawValue
        self.foregroundColor = self.color & 0x00FF
        if (value) {
            color = color & ~ForegroundColorMask.kNegate.rawValue
        }
        positive = value
    }
    
    func setAlternateTtsVoice(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kAlternateTTSVoice.rawValue : color & ~ForegroundColorMask.kAlternateTTSVoice.rawValue;
        self.foregroundColor = self.color & 0x00FF
        alternateTTSVoice = value
    }
    
    func setRepeatBoard(value: Bool) -> Void {
        color = !value ? color | ForegroundColorMask.kNoRepeats.rawValue : color & ~ForegroundColorMask.kNoRepeats.rawValue;
        self.foregroundColor = self.color & 0x00FF
        isRepeatBoard = value
    }
    
    func setRepeatChildBoards(value: Bool) -> Void {
        color = !value ? color | ForegroundColorMask.kNoRepeatsOnChildren.rawValue : color & ~ForegroundColorMask.kNoRepeatsOnChildren.rawValue;
        self.foregroundColor = self.color & 0x00FF
        isRepeatChildBoards = value
    }
    
    func setPopupStyleChildBoard(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kPopupStyleChildBoard.rawValue : color & ~ForegroundColorMask.kPopupStyleChildBoard.rawValue;
        self.foregroundColor = self.color & 0x00FF
        popupStyleChildBoard = value
    }
    
    func setAlternateTTSVoice(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kAlternateTTSVoice.rawValue : color & ~ForegroundColorMask.kAlternateTTSVoice.rawValue
        self.foregroundColor = self.color & 0x00FF
        alternateTTSVoice = value
    }
    
    func setHidden(value: Bool) -> Void {
        color = value ? color | ForegroundColorMask.kHidden.rawValue : color & ~ForegroundColorMask.kHidden.rawValue
        self.foregroundColor = self.color & 0x00FF
        hidden = value
    }
    
    func setRepeatOverlay(value: Bool) -> Void {
        setRepeat(value: value ? BackgroundColorMask.kOverlay : BackgroundColorMask.kNone)
        setAllRepeats()
    }
    
    func setRepeatRowTop(value: Bool) -> Void {
        setRepeat(value: value ? BackgroundColorMask.kTop : BackgroundColorMask.kNone)
        setAllRepeats()
    }
    
    func setRepeatRowBottom(value: Bool) -> Void {
        setRepeat(value: value ? BackgroundColorMask.kBottom : BackgroundColorMask.kNone)
        setAllRepeats()
    }
    
    func setRepeatColumnLeft(value: Bool) -> Void {
        setRepeat(value: value ? BackgroundColorMask.kLeft : BackgroundColorMask.kNone)
        setAllRepeats()
    }
    
    func setRepeatColumnRight(value: Bool) -> Void {
        setRepeat(value: value ? BackgroundColorMask.kRight : BackgroundColorMask.kNone)
        setAllRepeats()
    }
    
    func setColor(value: Int) -> Void {
        color = (color & 0xFF00) | value
        self.foregroundColor = self.color & 0x00FF
    }
    
    func setBackgroundColor(value: Int) -> Void {
        color = (color & 0xFF00) | value
        self.backgroundColor = self.backgroundColor & 0x00FF
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
                    let data = try Data(contentsOf: soundFileURL!)
                    speak.setAudioPlayer(try AVAudioPlayer(data: data)) {
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
    
    func copyLibraryContent(_ content: LibraryContent?) -> Content {
        if content != nil {
            self.id = content!.ContentId;
            self.name = content!.Text
            self.imageURL = content!.Picture ?? ""
            self.soundURL = content!.Sound ?? ""
            self.childBoardLink = content!.ChildBoardLinkId
            self.childBoardId = content!.ChildBoardId
            self.background = content!.Background
            self.color = content!.Foreground
            self.foregroundColor = self.color & 0x00FF
            self.fontSize = content!.FontSize
            self.zoom = content!.Zoom
            self.doNotAddToPhraseBar = content!.DoNotAddToPhraseBar
            self.doNotZoomPics = content!.DoNotZoomPics
            self.externalUrl = content!.ExternalUrl
            self.alternateTTS = content!.AlternateTtsText
            self.ttsSpeechPrompt = content!.TtsSpeechPrompt
            self.negate = (self.color & ForegroundColorMask.kNegate.rawValue) != 0
            self.alternateTTSVoice = (self.color & ForegroundColorMask.kAlternateTTSVoice.rawValue) != 0
            self.positive = (self.color & ForegroundColorMask.kPositive.rawValue) != 0
            self.repeatBoard = (self.color & ForegroundColorMask.kNoRepeats.rawValue) == 0
            self.repeatChildBoards = (self.color & ForegroundColorMask.kNoRepeatsOnChildren.rawValue) == 0
            self.popupStyleChildBoard = (self.color & ForegroundColorMask.kPopupStyleChildBoard.rawValue) != 0
            self.hidden = (self.color & ForegroundColorMask.kHidden.rawValue) != 0
            self.isRepeatBoard = (self.color & ForegroundColorMask.kNoRepeats.rawValue) == 0
            self.isRepeatChildBoards = (self.color & ForegroundColorMask.kNoRepeatsOnChildren.rawValue) == 0
            setAllRepeats()
        }
        return self;
    }
}

