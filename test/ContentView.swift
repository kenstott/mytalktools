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
    @AppStorage("ColorKey") var colorKey = "1"
    @Binding var maximumCellHeight: Double
    @Binding var cellWidth: Double
    @Binding var board: Board
    @State private var player: AVAudioPlayer? = nil
    @StateObject private var content = Content()
    @State var targeted: Bool = true
    
    private var onClick: (() -> Void)? = nil
    private var id: Int = 0
    func foregroundColor() -> Color {
        return _foregroundColor == "Black" ? Color.black : Color.white
    }
    func backgroundColor() -> Color {
        return _backgroundColor == "Black" ? Color.black : Color.white
    }
    func separatorLines() -> CGFloat {
        return _separatorLines ? 1 : 0
    }
    func defaultFontSize() -> CGFloat {
        return CGFloat(Double(_defaultFontSize) ?? 15)
    }
    
    init(_ id: Int, onClick: @escaping () -> Void, maximumCellHeight: Binding<Double>, cellWidth: Binding<Double>, board: Binding<Board> ) {
        self.id = id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
        self._board = board
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
                    }
            }
        }
    }
    
    var MainView: some View {
        ZStack {
            VStack {
                if content.urlImage != "" {
                    Image(String(content.urlImage.split(separator: ".").first!))
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .background(.clear)
                }
                Text(content.name)
                    .foregroundColor(foregroundColor())
                    .background(.clear)
                    .font(.system(size: defaultFontSize()))
            }
            .frame(width: cellWidth, height: maximumCellHeight)
            .padding(0)
            .background(.clear)
            if globalState.authorMode {
                Text(content.urlMedia)
                    .foregroundColor(Color.gray)
                    .background(.clear)
            }
            if content.childBoardId != 0 {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                    Image(systemName: "ellipsis")
                        .padding(5)
                        .alignmentGuide(.top) { $0[.bottom] - 20 }
                        .alignmentGuide(.trailing) { $0[.trailing] + 1 }
                        .foregroundColor(.gray)
                        .background(.clear)
                }
            }
        }
        .frame(minWidth: cellWidth, maxWidth: .infinity, minHeight: 0, maxHeight: maximumCellHeight)
        .border(foregroundColor(), width: separatorLines())
        .onAppear() {
            content.setId(id)
        }
        .padding(0)
        .background(backgroundColor())
    }
    
    var OverlayImage: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray)
                .opacity(0.2)
        }
        .frame(minWidth: cellWidth, maxWidth: .infinity, minHeight: 0, maxHeight: maximumCellHeight)
        .padding(0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            ContentView(45545, onClick: { () -> Void in }, maximumCellHeight: .constant(geo.size.height), cellWidth: .constant(geo.size.width), board: .constant(Board())).environmentObject(GlobalState())
        }
    }
}
