//
//  Speak.swift
//  test
//
//  Created by Kenneth Stott on 1/18/23.
//

import Foundation
import AVFAudio
import SwiftUI
import AudioToolbox
import AVFoundation


var player: AVAudioPlayer? = nil
var speakData: SpeakData? = nil


class SpeakData {
    
    var callback: (() -> Void)? = nil

    init(data: Data, closure: @escaping () -> Void) {
        do {
            player = try AVAudioPlayer(data: data)
            let durationInSeconds = player?.duration ?? 0
            DispatchQueue.main.asyncAfter(deadline: .now() + durationInSeconds) {
                closure()
            }
            callback = closure
        } catch let error {
            print(error.localizedDescription)
            closure()
        }
    }
    
    func play() {
        player?.stop()
        player?.prepareToPlay()
        player?.play()
    }
    
    func stop() {
        player?.stop()
    }
}

class Speak: NSObject, ObservableObject {
    
    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    var ttsVoiceAlternate: String?
    var ttsVoice = ""
    @Published var speaking = false
    var viewId: UUID?
    
    let APPLE_SPEECH_PREFIX = "com.apple.ttsbundle."
    let APPLE_SPEECH_PREFIX_ALT = "com.apple.voice.compact."
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var callback: (() -> Void)? = nil
    
    private var audioFileURL = URL(string: "")
    
    private func NilOrEmpty(_ s: String?) -> Bool { return s == nil || s == "" }
    
    func setAudioPlayer(_ data: Data, closure: @escaping () -> Void ) {
        speakData = SpeakData(data: data) {
            self.speaking = false
            closure()
        }
        speakData?.play()
    }
    
    func play() {
        speaking = true
    }
    
    func stop() {
        speaking = false
        speakData?.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func setVoices(_ ttsVoice: String, ttsVoiceAlternate: String?, closure: @escaping () -> Void ) {
        self.ttsVoiceAlternate = ttsVoiceAlternate
        self.ttsVoice = ttsVoice
        self.callback = closure
    }
    
    private func createAudioStream() -> AudioStreamBasicDescription {
        var audioStream = AudioStreamBasicDescription()
        audioStream.mSampleRate = 44100.0
        audioStream.mFormatID = kAudioFormatLinearPCM
        audioStream.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        audioStream.mFramesPerPacket = 1
        audioStream.mChannelsPerFrame = 1
        audioStream.mBitsPerChannel = 16
        audioStream.mBytesPerFrame = 2
        audioStream.mBytesPerPacket = 2
        
        return audioStream
    }
    
    func utter(_ phrase: String, speechRate: Double, voiceShape: Double, alternate: inout Bool?, fileURL: URL? = nil) {
        var output: AVAudioFile?
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
            audioFileURL = fileURL
            if (fileURL != nil) {
                speechSynthesizer.write(utterance) { buffer in
                    guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                        fatalError("unknown buffer type: \(buffer)")
                    }
                    if pcmBuffer.frameLength == 0 {
                        // Done - It seems that when recording TTS to an audio buffer that it sets iOS audio
                        // into a state that does not let you play audio files.
                        // I noticed that if you play a TTS phrase after recording it - it seems
                        // to reset the audio settings
                        var a1: Bool? = false
                        self.utter(phrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &a1)
                    } else {
                        do{
                            if output == nil {
                                try  output = AVAudioFile(
                                    forWriting: fileURL!,
                                    settings: pcmBuffer.format.settings,
                                    commonFormat: .pcmFormatInt16,
                                    interleaved: false)
                            }
                            try output?.write(from: pcmBuffer)
                            
                        }catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else {
                speechSynthesizer.speak(utterance)
            }
        }
    }
}

extension Speak: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) { speaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) { speaking = false}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) { speaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speaking = false
       // writeAudioFile()
        callback?()
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { speaking = false}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) { speaking = true }
}
