//
//  PhraseBar.swift
//  test
//
//  Created by Kenneth Stott on 1/25/23.
//

import Foundation

class PhraseBarState: NSObject, ObservableObject {
    
    @Published var userPhraseModeToggle = false
    @Published var contents: [Content] = []
    @Published var speakingItem = 0
    @Published var autoErase = false
    @Published var animate: (Int) -> Void = {_ in }
    @Published var phraseBarAnimate = false
    @Published var ttsVoice = ""
    @Published var ttsVoiceAlternate = ""
    @Published var speechRate = 0.0
    @Published var voiceShape = 0.0
    
    var speak = Speak()
    
    func speakPhraseCallback() {
        let nextItem = speakingItem
        speakingItem = 0
        speakPhrases(nextItem)
    }
    
    func speakPhrases(_ item: Int = 0) {
        if self.contents.count > item {
            self.animate(item)
            speakingItem = item + 1
            self.contents[item].voice(speak, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape, callback: speakPhraseCallback)
        } else if autoErase {
            self.contents.removeAll()
        } else if phraseBarAnimate {
            self.animate(0)
        }
        
    }
}

extension PhraseBarState: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        flag: Bool
    ) {
        print("hmmmm")
    }
}
