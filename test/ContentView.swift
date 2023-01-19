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
    @EnvironmentObject var globalState: GlobalState
    @AppStorage("SeparatorLines") var _separatorLines = true
    @AppStorage("ForegroundColor") var _foregroundColor = "Black"
    @AppStorage("BackgroundColor") var _backgroundColor = "White"
    @AppStorage("DefaultFontSize") var _defaultFontSize = ""
    @AppStorage("VisibleHotspots") var _visibleHotSpots = false
    @AppStorage("DisplayAsList") var displayAsList = false
    @AppStorage("ColorKey") var colorKey = "1"
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("SpeechRate") var speechRate: Double = 700
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    @Binding var maximumCellHeight: Double
    @Binding var cellWidth: Double
    @Binding var board: Board
    @Binding var content: Content
    @State private var player: AVAudioPlayer? = nil
    @State var targeted: Bool = true
    let speak: Speak;
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
    private var id: Int = 0
    
    init(_ content: Binding<Content>, onClick: @escaping () -> Void, maximumCellHeight: Binding<Double>, cellWidth: Binding<Double>, board: Binding<Board> ) {
        self.id = content.id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
        self._board = board
        self._content = content
        self.speak = Speak(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate)
    }
    
    var body: some View {
        ZStack {
            if globalState.authorMode && globalState.editMode {
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
                        let phrase = content.alternateTTS != "" ? content.alternateTTS : content.name
                        if (content.urlMedia != "") {
                            let sound = content.urlMedia.split(separator: ".")
                            let root = String(sound.first ?? "")
                            let ext = String(sound[1])
                            let soundFileURL = Bundle.main.url(forResource: root, withExtension: ext)
                            do {
                                if (soundFileURL != nil) {
                                    player = try AVAudioPlayer(contentsOf: soundFileURL!)
                                    player?.stop()
                                    player?.prepareToPlay()
                                    player?.play()
                                }
                            }
                            catch {
                                print("Problem playing: \(soundFileURL!)")
                            }
                            onClick!()
                        }
                        else  {
                            let phrase = content.alternateTTS != "" ? content.alternateTTS : content.name
                            var alternate: Bool? = content.alternateTTSVoice
                            speak.utter(phrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate)
                        }
                    }
            }
        }
    }
    
    var MainView: some View {
        ZStack {
            if (displayAsList) {
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
            ContentView(.constant(Content().setPreview()), onClick: { () -> Void in }, maximumCellHeight: .constant(geo.size.height), cellWidth: .constant(geo.size.width), board: .constant(Board())).environmentObject(GlobalState())
        }
    }
}
