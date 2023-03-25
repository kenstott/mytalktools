//
//  Speak.swift
//  test
//
//  Created by Kenneth Stott on 1/18/23.
//

import Foundation
import AVFAudio
import SwiftUI

class Speak: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    @Published var ttsVoiceAlternate: String?
    @Published var ttsVoice = ""
    @Published var speaking = false
    @Published var player: AVAudioPlayer? = nil
    @Published var viewId: UUID?

    private func NilOrEmpty(_ s: String?) -> Bool { return s == nil || s == "" }
    let APPLE_SPEECH_PREFIX = "com.apple.ttsbundle."
    let APPLE_SPEECH_PREFIX_ALT = "com.apple.voice.compact."
    let speechSynthesizer = AVSpeechSynthesizer()
    var callback: (() -> Void)? = nil
    func setAudioPlayer(_ player: AVAudioPlayer, closure: @escaping () -> Void ) {
        self.player = player
        self.player?.delegate = self
        self.callback = closure
    }
    
    func play() {
        speaking = true
        player?.stop()
        player?.prepareToPlay()
        player?.play()
    }
    
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        print(flag)
        if callback != nil {
            self.speaking = false;
            callback!()
        }
    }
    
    func setVoices(_ ttsVoice: String, ttsVoiceAlternate: String?, closure: @escaping () -> Void ) {
        self.ttsVoiceAlternate = ttsVoiceAlternate
        self.ttsVoice = ttsVoice
        self.callback = closure
    }
    
    func utter(_ phrase: String, speechRate: Double, voiceShape: Double, alternate: inout Bool?) {
        if (NilOrEmpty(phrase)) {
            return;
        }
        if (alternate == nil || NilOrEmpty(ttsVoiceAlternate)) {
            alternate = false
        }
        let voice = alternate! && !NilOrEmpty(ttsVoiceAlternate) ? ttsVoiceAlternate : ttsVoice;
        if (voice?.hasPrefix(APPLE_SPEECH_PREFIX) ?? false || voice?.hasPrefix(APPLE_SPEECH_PREFIX_ALT) ?? false) {
            let utterance = AVSpeechUtterance(string: phrase)
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice ?? "com.apple.ttsbundle.Samantha-compact")
            utterance.pitchMultiplier = 1.0
            utterance.rate = min(AVSpeechUtteranceMaximumSpeechRate, max(AVSpeechUtteranceMinimumSpeechRate, Float(speechRate) / 500.0));
            utterance.pitchMultiplier = (((Float(voiceShape) - 70.0) / 70.0) * 1.5) + 0.5;
            speechSynthesizer.speak(utterance)
        }
    }
    
}

extension Speak: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) { speaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) { speaking = false}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) { speaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speaking = false
        callback?()
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { speaking = false}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) { speaking = true }
}

