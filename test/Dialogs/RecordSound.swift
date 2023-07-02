//
//  RecordSound.swift
//  test
//
//  Created by Kenneth Stott on 5/12/23.
//

import SwiftUI
import AVFoundation

struct RecordSound: View {
    
    enum AudioState {
        case initial, stopped, playing, recording
    }
    
    @Binding var cellText: String
    @Binding var filename: String
    @ObservedObject var speak = Speak()
    @State var audioState: AudioState = .initial
    @State var recordingTimer = ""
    @State var runCount: TimeInterval = Date().timeIntervalSince1970
    @State var recorder: AVAudioRecorder? = nil
    @State var fileURL: URL? = nil
    @State var session: AVAudioSession? = nil
    
    @EnvironmentObject var userState: User
    @Environment(\.dismiss) var dismiss
    
    let formatter = DateComponentsFormatter()
    
    var body: some View {
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if audioState == .recording || audioState == .playing {
                recordingTimer = formatter.string(from: Date().timeIntervalSince1970 - runCount)!
            }
        }
        
        return NavigationView {
            VStack {
                Spacer()
                Text(cellText)
                Spacer()
                if audioState == .recording || audioState == .stopped || audioState == .playing {
                    Text(recordingTimer)
                }
                Spacer()
                HStack {
                    Button {
//                        print("Record")
                        runCount = Date().timeIntervalSince1970
                        audioState = .recording
                        recorder?.record()
                        
                    } label: {
                        Label(LocalizedStringKey("Record"), systemImage: "record.circle").foregroundColor(.red)
                    }.disabled(audioState == .playing || audioState == .recording || speak.speaking == true)
                    Button {
//                        print("Play")
                        runCount = Date().timeIntervalSince1970
                        audioState = .playing
                        do {
                            speak.setAudioPlayer(try Data(contentsOf: fileURL!)) {
                                audioState = .stopped
                            }
                            speak.play()
                        } catch let error {
                            print(error.localizedDescription)
                            audioState = .stopped
                        }
                    } label: {
                        Label(LocalizedStringKey("Play"), systemImage: "play.circle")
                    }.disabled(audioState == .recording || audioState == .initial || audioState == .playing)
                    Button {
//                        print("Stop")
                        audioState = .stopped
                        recorder?.stop()
                        speak.stop()
                    } label: {
                        Label(LocalizedStringKey("Stop"), systemImage: "stop.circle")
                    }.disabled(audioState != .playing && audioState != .recording)
                }
                Spacer()
            }
            
            .onAppear {
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .full
                fileURL = Media.generateFileName(str: cellText, username: userState.username, ext: "wav")
                session = AVAudioSession.sharedInstance()
                try? session?.setCategory(.playAndRecord, mode: .default)
                try? session?.setActive(true)
                recorder = try? AVAudioRecorder(url: fileURL!, settings: [:])
            }
            .navigationBarTitle("Record Sound")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        filename = "\(userState.username)/Private Library/\(fileURL!.lastPathComponent)"
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("Save"))
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("Cancel"))
                    }
                    
                }
            }
        }
    }
}

struct RecordSound_Previews: PreviewProvider {
    static var previews: some View {
        RecordSound(cellText: .constant("test"), filename: .constant("")).environmentObject(User())
    }
}
