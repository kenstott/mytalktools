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

struct ContentView: View {
    
    @EnvironmentObject var boardState: BoardState
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
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
    
    init(_ content: Binding<Content>, onClick: @escaping () -> Void, maximumCellHeight: Binding<Double>, cellWidth: Binding<Double>, board: Binding<Board> ) {
        self.contentId = content.id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
        self._board = board
        self._content = content
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
                        return board.swap(id1: content.id, id2: Int(provider.first?.suggestedName ?? "") ?? -1)
                    })
                    .onDrag {
                        let item = NSItemProvider(object: NSString(string: String(self.content.id)))
                        item.suggestedName = String(self.content.id)
                        return item
                    }
                    .onTapGesture {
                        print("Show edit menu")
                    }
                
            } else {
                MainView
                    .onTapGesture {
                        if (phraseMode == "1") {
                            switch content.contentType {
                            case .goBack:
                                break;
                            case .goHome:
                                break;
                            default:
                                if (content.link == 0) {
                                    phraseBarState.contents.append(content)
                                }
                            }
                        } else {
                            content.voice(speak, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape) {
                                print("done")
                            }
                            if content.boardId == -1 && content.linkId != 0 {
                                self.linkID = content.linkId
                            }
                        }
                        onClick!()
                    }
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
            ContentView(.constant(Content().setPreview()), onClick: { () -> Void in }, maximumCellHeight: .constant(geo.size.height), cellWidth: .constant(geo.size.width), board: .constant(Board())).environmentObject(BoardState())
        }
    }
}
