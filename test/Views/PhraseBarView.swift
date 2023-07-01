//
//  PhraseBar.swift
//  test
//
//  Created by Kenneth Stott on 1/24/23.
//

import SwiftUI

struct PhraseBarView: View {
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
    @AppStorage("PhraseBarAutoErase") var autoErase = false
    @AppStorage("PhraseBarTimeOut") var eraseTimeout: Double = 0
    @AppStorage("PhraseBarAnimate") var phraseBarAnimate = false
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("SpeechRate") var speechRate: Double = 200
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    @State var playing = false
    @State var lastInteraction = Date.now
    @State var timer: Timer? = nil
    @State var proxy: ScrollViewProxy? = nil

    func animate(id: Int) -> Void {
        if phraseBarAnimate {
            DispatchQueue.main.async {
                withAnimation {
                    proxy!.scrollTo(id)
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            ScrollViewReader { value in
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(Array(phraseBarState.contents.enumerated()), id: \.offset) { offset, item in
                            ZStack(alignment: .center) {
                                ContentView(
                                    .constant(item),
                                    selectMode: false,
                                    onClick: { () -> Void in
                                    },
                                    maximumCellHeight: .constant(80),
                                    cellWidth: .constant(80),
                                    board: .constant(Board()),
                                    refresh: 0,
                                    zoomHeight: 250.0,
                                    zoomWidth: 250.0
                                )
                                .id(offset + 1)
                                .overlay(offset + 1 == phraseBarState.speakingItem ? Image(systemName: "speaker.wave.3").padding(0).foregroundColor(.gray).background(.clear).imageScale(.small) : nil, alignment: .topLeading)
                            }
                        }
                    }
                }
                .padding([.leading,.trailing], 20)
                .onReceive(phraseBarState.$contents) { contents in
                    proxy = value
                    lastInteraction = Date.now
                    DispatchQueue.main.async {
                        withAnimation {
                            value.scrollTo(contents.count)
                        }
                    }
                }
            }
            Spacer()
            Button {
                print("delete")
            } label: {
                Image(systemName: "delete.backward.fill")
                    .font(.system(size: 40))
                    .offset(x: -15)
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        if !phraseBarState.contents.isEmpty {
                            phraseBarState.contents.removeAll()
                        }
                    }
            )
            .highPriorityGesture(TapGesture()
                .onEnded { _ in
                    if !phraseBarState.contents.isEmpty {
                        phraseBarState.contents.removeLast()
                    }
                })
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (track) in
                    if eraseTimeout > 0 && !phraseBarState.contents.isEmpty && track.fireDate.timeIntervalSince(lastInteraction) > eraseTimeout / 100 {
                        phraseBarState.contents.removeAll()
                    }
                }
            }
            Button {
//                print("play")
                phraseBarState.speakPhrases()
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 40))
                    .offset(x: -15)
            }
            .disabled($phraseBarState.contents.count == 0)
        }
        .frame(minHeight: 100)
        .border(Color.gray)
        .onReceive(speak.$speaking) { speaking in
//            print(speaking)
        }
        .onAppear {
            phraseBarState.animate = animate
            phraseBarState.ttsVoice = ttsVoice
            phraseBarState.ttsVoiceAlternate = ttsVoiceAlternate
            phraseBarState.speechRate = speechRate
            phraseBarState.voiceShape = voiceShape
        }
    }
}

struct PhraseBar_Previews: PreviewProvider {
    static var previews: some View {
        PhraseBarView()
    }
}
