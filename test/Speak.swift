//
//  Speak.swift
//  test
//
//  Created by Kenneth Stott on 1/18/23.
//

import Foundation
import AVFAudio

class Speak {
    
    private var ttsVoiceAlternate: String?
    private var ttsVoice = ""
    private func NilOrEmpty(_ s: String?) -> Bool { return s == nil || s == "" }
    let APPLE_SPEECH_PREFIX = "com.apple.ttsbundle."
    let APPLE_SPEECH_PREFIX_ALT = "com.apple.voice.compact."
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func setVoices(_ ttsVoice: String, ttsVoiceAlternate: String?) {
        self.ttsVoiceAlternate = ttsVoiceAlternate
        self.ttsVoice = ttsVoice
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
            //utterance.rate = min(AVSpeechUtteranceMaximumSpeechRate, max(AVSpeechUtteranceMinimumSpeechRate, Float(speechRate) / 500));
            utterance.pitchMultiplier = (((Float(voiceShape) - 70.0) / 70.0) * 1.5) + 0.5;
            speechSynthesizer.speak(utterance)
        }
    }
}

