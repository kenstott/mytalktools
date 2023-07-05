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
        acapelaLicense = AcapelaLicense(
            license: acattsioslicense.license(),
            user: acattsioslicense.userid(),
            passwd: acattsioslicense.password())
        self.voices = AcapelaSpeech.availableVoices()
        self.speechSynthesizer.delegate = self
    }
    
    @Published var speaking = false
    @Published var loadingSpeechFiles = false

    var ttsVoiceAlternate: String?
    var ttsVoice = ""
    var viewId: UUID?
    var acapelaLicense: AcapelaLicense?
    var voices: [Any] = []
    var primaryVoice: AcapelaSpeech?
    var alternateVoice: AcapelaSpeech?
    var currentVoiceName: String?
    
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
        if ttsVoice != self.ttsVoice && ttsVoice.hasSuffix(".bvcu") {
            self.ttsVoice = ttsVoice
            DispatchQueue.main.async { [self] in
                loadingSpeechFiles = true
            }
            downloadVoice(alternate: false, force: false) { [self] err, dirDicoPath in
                primaryVoice = AcapelaSpeech()
                primaryVoice?.setUserDicoPath(dirDicoPath)
                primaryVoice?.loadVoice(
                    ttsVoice,
                    license: acattsioslicense.license(),
                    userid: Int(acattsioslicense.userid()),
                    password: Int(acattsioslicense.password()),
                    mode: "")
                primaryVoice?.setVolume(1)
                primaryVoice?.setDelegate(self)
                DispatchQueue.main.async { [self] in
                    loadingSpeechFiles = false
                }
            }
        }
        if ttsVoiceAlternate != nil && ttsVoiceAlternate != self.ttsVoiceAlternate && ttsVoiceAlternate!.hasSuffix(".bvcu") {
            self.ttsVoiceAlternate = ttsVoiceAlternate
            DispatchQueue.main.async { [self] in
                loadingSpeechFiles = true
            }
            downloadVoice(alternate: true, force: false) { [self] err, dirDicoPath in
                alternateVoice = AcapelaSpeech()
                alternateVoice?.setUserDicoPath(dirDicoPath)
                alternateVoice?.loadVoice(
                    ttsVoiceAlternate,
                    license: acattsioslicense.license(),
                    userid: Int(acattsioslicense.userid()),
                    password: Int(acattsioslicense.password()),
                    mode: "")
                alternateVoice?.setVolume(1)
                alternateVoice?.setDelegate(self)
                DispatchQueue.main.async { [self] in
                    loadingSpeechFiles = false
                }
            }
        }
        self.ttsVoice = ttsVoice
        self.ttsVoiceAlternate = ttsVoiceAlternate
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
        if voice!.hasSuffix(".bvcu") {
            if alternate! {
                alternateVoice?.setRate(Float(speechRate))
                alternateVoice?.setVoiceShaping(Int32(voiceShape))
                alternateVoice?.startSpeaking(phrase)
            } else {
                primaryVoice!.setRate(Float(speechRate))
                primaryVoice!.setVoiceShaping(Int32(voiceShape))
                print(Float(speechRate))
                print(primaryVoice!.voiceShaping())
                print(primaryVoice!.rate())
                primaryVoice!.startSpeaking(phrase)
            }
        }
    }
    
    func downloadVoice(alternate: Bool, force: Bool, callback: @escaping (Bool, String) -> Void) -> Void {
        var _voiceName: String?
        var _languageName: String?
        var _shortLanguageName: String?
        
        var foo = (alternate ? ttsVoiceAlternate! : ttsVoice).split(separator: "_").map { String($0) }
        if foo.count < 2 {
            callback(false, "")
            return
        }
        if (alternate ? ttsVoiceAlternate! : ttsVoice).hasSuffix("_ns.bvcu") {
            if (foo.count == 4) {
                _shortLanguageName = foo[0];
                _voiceName = foo[1]
            } else {
                _shortLanguageName = "\(foo[0])_\(foo[1])"
                _voiceName = foo[2]
            }
        } else {
            if (foo.count == 5) {
                _shortLanguageName = foo[0]
                _voiceName = foo[2]
            } else {
                _shortLanguageName = "\(foo[0])_\(foo[1])"
                _voiceName = foo[3];
            }
        }
        let voiceName = _voiceName
        let shortLanguageName = _shortLanguageName
        
        let voices = AcapelaSpeech.availableVoices() ?? []
        let voiceNum = (voices as! [String]).firstIndex(of: (alternate ? ttsVoiceAlternate! : ttsVoice).lowercased())
        if voiceNum == nil {
            callback(false, "")
            return
        }
        
        let currentVoice = voices[voiceNum!]
        let voiceDictionary = AcapelaSpeech.attributes(forVoice: currentVoice as? String) ?? [AnyHashable:Any]()
        self.currentVoiceName = "\(voiceDictionary[AcapelaVoiceName]!)";
        
        _languageName = "\(voiceDictionary[AcapelaVoiceRelativePathToApp]!)";
        foo = _languageName!.split(separator: "/").map { String($0) }
        foo = foo[1].split(separator: "-").map { String($0) }
        _languageName = foo[2];
        
        let languageName = _languageName
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let dirDicoPath = documentsURL!.appendingPathComponent("acapela/hq-lf-\(languageName!)-\(voiceName!)-22khz/\(shortLanguageName!)")
        let nlpPath = dirDicoPath.appendingPathComponent("NLP")
        let t = (alternate ? ttsVoiceAlternate! : ttsVoice).hasSuffix("_ns.bvcu") ? "ns" : "lf"
        let lfPath = dirDicoPath.appendingPathComponent("\(voiceName!.lowercased())_\(t)")
        
        if !FileManager.default.fileExists(atPath: nlpPath.path) {
            Task {
                do {
                    try FileManager.default.createDirectory(at: nlpPath, withIntermediateDirectories: true)
                    try FileManager.default.createDirectory(at: lfPath, withIntermediateDirectories: true)
                    let fullDicoPath = dirDicoPath.appendingPathComponent("default.userdico")
                    if !FileManager.default.fileExists(atPath: fullDicoPath.path) {
                        try "UserDico\n".write(to: fullDicoPath, atomically: true, encoding: .isoLatin1)
                    }
                    var inputDir = "NLP"
                    var libraryName = "hq-lf-\(languageName!)-\(voiceName!)-22khz\\\(shortLanguageName!)\\\(inputDir)"
                    var result = try await Files.getFiles.execute(params: DocumentFileListInput(userName: "acapela.voices.3", libraryName: libraryName, searchPattern: "*.*"))
                    if result == nil {
                        callback(false, "")
                        return
                    }
                    var outputPath = dirDicoPath.appendingPathComponent(inputDir)
                    for item in result!.d {
                        if item.Name != inputDir {
                            let filename = "https://www.mytalktools.com/dnn/UserUploads/acapela.voices.3/hq-lf-\(languageName!)-\(voiceName!)-22khz/\(shortLanguageName!)/\(inputDir)/\(item.Name)"
                            let url = outputPath.appendingPathComponent(item.Name)
                            let data = try Data(contentsOf: URL(string: filename)!)
                            try data.write(to: url)
                        }
                    }
                    inputDir = "\(voiceName!.lowercased())_\(t)"
                    libraryName = "hq-lf-\(languageName!)-\(voiceName!)-22khz\\\(shortLanguageName!)\\\(inputDir)"
                    result = try await Files.getFiles.execute(params: DocumentFileListInput(userName: "acapela.voices.3", libraryName: libraryName, searchPattern: "*.*"))
                    if result == nil {
                        callback(false, "")
                        return
                    }
                    outputPath = dirDicoPath.appendingPathComponent(inputDir)
                    for item in result!.d {
                        if item.Name != inputDir {
                            let filename = "https://www.mytalktools.com/dnn/UserUploads/acapela.voices.3/hq-lf-\(languageName!)-\(voiceName!)-22khz/\(shortLanguageName!)/\(inputDir)/\(item.Name)"
                            let data = try Data(contentsOf: URL(string: filename)!)
                            try data.write(to: outputPath.appendingPathComponent(item.Name))
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                    callback(false, "")
                    return
                }
                callback(true, dirDicoPath.path)
            }
        } else {
            callback(true, dirDicoPath.path)
        }
    }
    
    override func speechSynthesizer(_ sender: AcapelaSpeech, didFinishSpeaking finishedSpeaking: Bool) {
        speaking = false
        callback?()
    }
    
    func speechSynthesizer(_ sender: AcapelaSpeech, didFinishSpeaking finishedSpeaking: Bool, textIndex index: Int) {
        speaking = false
        callback?()
    }
    override func speechSynthesizer(_ sender: AcapelaSpeech, willSpeakWord characterRange: NSRange, of string: String) {
        speaking = true
    }
    override func speechSynthesizer(_ sender: AcapelaSpeech, willSpeakViseme visemeCode: Int16) {
        speaking = true
    }
    override func speechSynthesizer(_ sender: AcapelaSpeech, didEncounterSyncMessage errorMessage: String) {
        print(errorMessage)
        speaking = false
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

