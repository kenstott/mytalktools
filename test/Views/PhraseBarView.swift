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
    @State var timer: Timer?
    @State var proxy: ScrollViewProxy?
    @State var speakingItem = 0
    
    func speakPhrases(_ pbs: PhraseBarState, _ spk: Speak, _ item: Int = 0) {
        if pbs.contents.count > item {
            if phraseBarAnimate {
                DispatchQueue.main.async {
                    withAnimation {
                        proxy!.scrollTo(item)
                    }
                }
            }
            speakingItem = item + 1
            pbs.contents[item].voice(spk, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape) {
                speakingItem = 0
                speakPhrases(pbs, spk, item + 1)
            }
        } else if autoErase {
            pbs.contents.removeAll()
        } else if phraseBarAnimate {
            DispatchQueue.main.async {
                withAnimation {
                    proxy!.scrollTo(0)
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
                                    onClick: { () -> Void in
                                    },
                                    maximumCellHeight: .constant(80),
                                    cellWidth: .constant(80),
                                    board: .constant(Board()),
                                    refresh: 0
                                )
                                .id(offset + 1)
                                .overlay(offset + 1 == speakingItem ? Image(systemName: "speaker.wave.3").padding(0).foregroundColor(.gray).background(.clear).imageScale(.small) : nil, alignment: .topLeading)
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
                print("play")
                speakPhrases(phraseBarState, speak)
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
            print(speaking)
        }
    }
}

struct PhraseBar_Previews: PreviewProvider {
    static var previews: some View {
        PhraseBarView()
    }
}
