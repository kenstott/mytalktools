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
    @EnvironmentObject var dataWrapper: DataWrapper
    @Binding var maximumCellHeight: Double
    @Binding var cellWidth: Double
    @State private var canTouchDown = true
    @State private var player: AVAudioPlayer? = nil
    @State private var changeCount = 0;
    @StateObject private var content = Content()
    
    private var onClick: (() -> Void)? = nil
    private var id: Int = 0
    private var settings = UserDefaults.standard.dictionaryRepresentation()
    
    init(_ id: Int, onClick: @escaping () -> Void, maximumCellHeight: Binding<Double>, cellWidth: Binding<Double> ) {
        self.id = id;
        self.onClick = onClick
        self._maximumCellHeight = maximumCellHeight
        self._cellWidth = cellWidth
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                if content.urlImage != "" {
                    Image(String(content.urlImage.split(separator: ".").first!))
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                }
                Text(content.name)
            }
            .frame(width: cellWidth, height: maximumCellHeight)
            .border(Color.black, width: 1)
            .padding(0)
            if (!canTouchDown) {
                OverlayImage
            }
            if (dataWrapper.authorMode) {
                Text(content.urlMedia).foregroundColor(Color.gray)
            }
        }
        .frame(minWidth: cellWidth, maxWidth: .infinity, minHeight: 0, maxHeight: maximumCellHeight)
        .onAppear() {
            content.setId(id)
        }
        .padding(0)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                print("onchange")
                changeCount += 1
                canTouchDown = false
            }
            .onEnded { value in
                print("onended")
                if (!canTouchDown) {
                    canTouchDown = true
                    if (content.urlMedia != "" && abs(value.predictedEndTranslation.height) < 200 && changeCount < 6) {
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
                changeCount = 0
            })
        
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
        ContentView(45545, onClick: { () -> Void in }, maximumCellHeight: .constant(100.0), cellWidth: .constant(100.0)).environmentObject(DataWrapper())
    }
}
