//
//  ContentView.swift
//  test
//
//  Created by Kenneth Stott on 12/31/22.
//

import SwiftUI
import FMDB
import AVKit
import AVFAudio

enum ActionSheetType {
    case top
    case board
}

struct ContentView: View {
    
    @EnvironmentObject var boardState: BoardState
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
    @EnvironmentObject var scheduleMonitor: ScheduleMonitor
    @AppStorage("SeparatorLines") var _separatorLines = true
    @AppStorage("PhraseMode") var phraseMode = "0"
    @AppStorage("ForegroundColor") var _foregroundColor = "Black"
    @AppStorage("BackgroundColor") var _backgroundColor = "White"
    @AppStorage("DefaultFontSize") var _defaultFontSize = ""
    @AppStorage("VisibleHotspots") var _visibleHotSpots = false
    @AppStorage("DisplayAsList") var displayAsList = false
    @AppStorage("ColorKey") var colorKey = "1"
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("SpeechRate") var speechRate: Double = 200
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    @AppStorage("PhraseBarAnimate") var phraseBarAnimate = false
    @AppStorage("ZoomPictures") var zoomPictures = false
    @AppStorage("UnzoomInterval") var unzoomInterval = 0
    @Binding var maximumCellHeight: Double
    @Binding var cellWidth: Double
    @Binding var board: Board
    @Binding var content: Content
    private var zoomHeight: Double = 250
    private var zoomWidth: Double = 250
    @State var targeted: Bool = true
    @State var id = UUID()
    @State var linkID: UInt?
    @State var showEditCellActionSheet = false
    @State var showEditActionSheet = false
    @State var showBoardSortOrderSheet = false
    @State var zoomId: Int? = -1
    @State var actionSheetType: ActionSheetType = .top
    @State var selectMode = false
    private var fromPhraseBar = false
    
    @Environment(\.presentationMode) var presentationMode
    
    private var separatorLines: CGFloat {
        get {
            return _separatorLines ? 1 : 0
        }
    }
    private var foregroundColor: Color {
        get {
            return _foregroundColor == "Black" ? Color.black : Color.white
        }
    }
    private var backgroundColor: Color {
        return _backgroundColor == "Black" ? Color.black : Color.white
    }
    private var defaultFontSize: CGFloat {
        get {
            return CGFloat(Double(_defaultFontSize) ?? 15)
        }
    }
    private var onClick: ((_ taps: Int) -> Void)? = nil
    private var contentId: Int = 0
    private var refresh = 0
    
    init(
        _ content: Binding<Content>,
        selectMode: Bool,
        onClick: @escaping (_ taps: Int) -> Void,
        maximumCellHeight: Binding<Double>,
        cellWidth: Binding<Double>,
        board: Binding<Board>,
        refresh: Int,
        zoomHeight: Double,
        zoomWidth: Double,
        fromPhraseBar: Bool = false
    ) {
        self.contentId = content.id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
        self._board = board
        self._content = content
        self.refresh = refresh
        self.zoomHeight = zoomHeight
        self.zoomWidth = zoomWidth
        self.fromPhraseBar = fromPhraseBar
    }
    
    func save(content: Content) {
        boardState.createUndoSlot();
        content.save();
        self.content = content
        showEditCellActionSheet = false
        let _ = board.setId(board.id, nil)
        scheduleMonitor.createSchedule()
    }
    
    func cancel() {
        showEditCellActionSheet = false
    }
    
    func cellAction(taps: Int = 1) {
        DispatchQueue.main.async {
            if !self.fromPhraseBar {
                if taps == 1 {
                    if phraseMode == "1" || phraseBarState.userPhraseModeToggle {
                        switch content.contentType {
                        case .goBack:
                            break;
                        case .goHome:
                            break;
                        default:
                            if !content.doNotAddToPhraseBar {
                                phraseBarState.appendToContents(content);
                            }
                        }
                    } else {
                        if content.linkId == 0 && content.externalUrl == "" && ((zoomPictures && !content.doNotZoomPics) || content.zoom) {
                            zoomId = content.id
                        }
                        content.voice(speak, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape) {
                            //                    print("done")
                        }
                        if content.boardId == -1 && content.linkId != 0 {
                            self.linkID = content.linkId
                        }
                        if (content.externalUrl != "") {
                            if let url = URL(string: content.externalUrl) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    }
                }
            }
            onClick!(taps)
        }
    }
    
    func getButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [
            .cancel { showEditActionSheet = false },
            .default(Text(LocalizedStringKey("Sort Order")), action: {
                showEditActionSheet = false
                showBoardSortOrderSheet = true
            }),
            .default(Text(LocalizedStringKey("Add Row")), action: {
                board.addRow(boardState: boardState)
            }),
            .default(Text(LocalizedStringKey("Add Column")), action: {
                board.addColumn(boardState: boardState)
            }),
            .default(Text(LocalizedStringKey("Stretch Columns By 1")), action: {
                board.stretchColumns(boardState: boardState)
            })
        ]
        if board.columns > 1 {
            buttons.append(.default(Text(LocalizedStringKey("Compress Columns By 1")), action: {
                board.compressColumns(boardState: boardState)
            }))
            buttons.append(.default(Text(LocalizedStringKey("Delete Right Column")), action: {
                board.deleteRightColumn(boardState: boardState)
            }))
        }
        if board.rows > 1 {
            buttons.append(.default(Text(LocalizedStringKey("Delete Last Row")), action: {
                board.deleteLastRow(boardState: boardState)
            }))
        }
        return buttons
    }
    
    var body: some View {
        return ZStack {
            if content.boardId == -1 && content.linkId != 0 {
                GeometryReader { geometry in
                    NavigationLink(destination: BoardView(content.linkId, geometry: geometry), tag: content.linkId, selection: $linkID) { EmptyView() }
                }
            }
            if content.linkId == 0 && content.externalUrl == "" && ((zoomPictures && !content.doNotZoomPics) || content.zoom) {
                NavigationLink(
                    destination: ContentGridCell(
                        content,
                        defaultFontSize: defaultFontSize * 2,
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                        maximumCellHeight: zoomHeight,
                        cellWidth: zoomWidth,
                        separatorLines: separatorLines,
                        unzoomInterval: unzoomInterval
                    )
                        .onTapGesture {
                            content.voice(speak, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape) {
                                //                    print("done")
                            }
                        },
                    tag: content.id,
                    selection: $zoomId) {
                        EmptyView() }
                
            }
            if boardState.authorMode && boardState.editMode {
                MainView
                    .onDrop(of: ["public.utf8-plain-text"], isTargeted: self.$targeted,
                            perform: { (provider) -> Bool in
                        return board.swap(id1: content.id, id2: Int(provider.first?.suggestedName ?? "") ?? -1, boardState: boardState)
                    })
                    .onDrag {
                        let item = NSItemProvider(object: NSString(string: String(self.content.id)))
                        item.suggestedName = String(self.content.id)
                        return item
                    }
                    .onTapGesture {
                        //                        print("Show edit menu")
                        showEditActionSheet = false
                        DispatchQueue.main.async {
                            actionSheetType = .top
                            showEditActionSheet = true
                        }
                    }
                
            } else {
                MainView
                    .onTapGesture(count: 2) {
                        cellAction(taps: 2)
                    }
                    .onTapGesture {
                        cellAction()
                    }
            }
        }
        .sheet(isPresented: $showEditCellActionSheet) {
            EditCell(content: content, save: save, cancel: cancel)
        }
        .sheet(isPresented: $showBoardSortOrderSheet) {
            BoardSortOrder(
                save: {
                    showBoardSortOrderSheet = false
                }
                ,cancel: {
                    showBoardSortOrderSheet = false
                }
            )
        }
        .actionSheet(isPresented: $showEditActionSheet) {
            switch(actionSheetType) {
            case .board: return ActionSheet(
                title: Text(LocalizedStringKey("Change Board Dimensions")),
                buttons: getButtons()
            )
            case .top:
                let repeatButton: [ActionSheet.Button] = [.default(Text(LocalizedStringKey("Repeat")), action: {})]
                var buttons: [ActionSheet.Button] = [
                    .cancel {
                        //                        print("cancel")
                        
                    },
                    .default(Text("\(NSLocalizedString("Edit Cell", comment: ""))-\(content.name)"), action: {
                        showEditActionSheet = false
                        showEditCellActionSheet = true
                    }),
                    .default(Text("\(NSLocalizedString("Perform Action", comment: ""))-\(content.name)"), action: {
                        cellAction()
                    }),
                    .default(Text("\(NSLocalizedString("Edit Board", comment: ""))-\(board.name)"), action: {
                        showEditActionSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            actionSheetType = .board
                            showEditActionSheet = true
                        }
                    })]
                if board.name == "Home" {
                    buttons.append(repeatButton[0])
                }
                return ActionSheet(
                    title: Text(LocalizedStringKey("Edit Options")),
                    buttons: buttons
                )
            }
        }
    }
    
    var MainView: some View {
        ZStack {
            if displayAsList {
                ContentListRow(content, defaultFontSize: defaultFontSize, foregroundColor: foregroundColor)
            } else {
                ContentGridCell(content, defaultFontSize: defaultFontSize, foregroundColor: foregroundColor, backgroundColor: backgroundColor, maximumCellHeight: maximumCellHeight, cellWidth: cellWidth, separatorLines: separatorLines)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ContentView(.constant(Content().setPreview()), selectMode: false, onClick: { (taps: Int) -> Void in }, maximumCellHeight: .constant(geo.size.height), cellWidth: .constant(geo.size.width), board: .constant(Board()), refresh: 0, zoomHeight: 250.0, zoomWidth: 250.0).environmentObject(BoardState())
        }
    }
}
