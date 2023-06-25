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
    @Binding var maximumCellHeight: Double
    @Binding var cellWidth: Double
    @Binding var board: Board
    @Binding var content: Content
    @State var targeted: Bool = true
    @State var id = UUID()
    @State var linkID: UInt?
    @State var showEditCellActionSheet = false
    @State var showEditActionSheet = false
    @State var showBoardSortOrderSheet = false
    @State var actionSheetType: ActionSheetType = .top
    @State var selectMode = false
    
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
    private var onClick: (() -> Void)? = nil
    private var contentId: Int = 0
    private var refresh = 0
    
    init(_ content: Binding<Content>, selectMode: Bool, onClick: @escaping () -> Void, maximumCellHeight: Binding<Double>, cellWidth: Binding<Double>, board: Binding<Board>, refresh: Int ) {
        self.contentId = content.id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
        self._board = board
        self._content = content
        self.refresh = refresh
    }
    
    func save(content: Content) {
//        print("Save")
        boardState.createUndoSlot();
        content.save();
        self.content = content
        showEditCellActionSheet = false
        let _ = board.setId(board.id, nil)
        scheduleMonitor.createSchedule()
    }
    
    func cancel() {
//        print("Cancel")
        showEditCellActionSheet = false
    }
    
    func cellAction() {
        DispatchQueue.main.async {
            if (phraseMode == "1" || phraseBarState.userPhraseModeToggle) {
                switch content.contentType {
                case .goBack:
                    break;
                case .goHome:
                    break;
                default:
                    if !content.doNotAddToPhraseBar {
                        phraseBarState.contents.append(content)
                    }
                }
            } else {
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
            onClick!()
        }
    }
    
    func getButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [
            .cancel { showEditActionSheet = false },
            .default(Text("Sort Order"), action: {
                showEditActionSheet = false
                showBoardSortOrderSheet = true
            }),
            .default(Text("Add Row"), action: {
                board.addRow(boardState: boardState)
            }),
            .default(Text("Add Column"), action: {
                board.addColumn(boardState: boardState)
            }),
            .default(Text("Stretch Columns By 1"), action: {
                board.stretchColumns(boardState: boardState)
            })
        ]
        if board.columns > 1 {
            buttons.append(.default(Text("Compress Columns By 1"), action: {
                board.compressColumns(boardState: boardState)
            }))
            buttons.append(.default(Text("Delete Right Column"), action: {
                board.deleteRightColumn(boardState: boardState)
            }))
        }
        if board.rows > 1 {
            buttons.append(.default(Text("Delete Last Row"), action: {
                board.deleteLastRow(boardState: boardState)
            }))
        }
        return buttons
    }
    
    var body: some View {
        ZStack {
            if content.boardId == -1 && content.linkId != 0 {
                GeometryReader { geometry in
                    NavigationLink(destination: BoardView(content.linkId, geometry: geometry), tag: content.linkId, selection: $linkID) { EmptyView() }
                }
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
                title: Text("Change Board Dimensions"),
                buttons: getButtons()
            )
            case .top:
                let repeatButton: [ActionSheet.Button] = [.default(Text("Repeat"), action: {})]
                var buttons: [ActionSheet.Button] = [
                    .cancel {
//                        print("cancel")
                        
                    },
                    .default(Text("Edit Cell-\(content.name)"), action: {
                        showEditActionSheet = false
                        showEditCellActionSheet = true
                    }),
                    .default(Text("Perform Action-\(content.name)"), action: {
                        cellAction()
                    }),
                    .default(Text("Edit Board-\(board.name)"), action: {
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
                    title: Text("Edit Options"),
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
            ContentView(.constant(Content().setPreview()), selectMode: false, onClick: { () -> Void in }, maximumCellHeight: .constant(geo.size.height), cellWidth: .constant(geo.size.width), board: .constant(Board()), refresh: 0).environmentObject(BoardState())
        }
    }
}
