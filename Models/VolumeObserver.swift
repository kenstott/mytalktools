//
//  VolumeObserver.swift
//  test
//
//  Created by Kenneth Stott on 5/20/23.
//

import Foundation

var volumeIcons = ["speaker.slash","speaker.wave.1","speaker.wave.2","speaker.wave.3"]

final class VolumeObserver: ObservableObject {
    
    func getVolumeIcon(volume: Float) -> String {
        if volume == 0.0 {
            return volumeIcons[0]
        }
        if volume < 0.33 {
            return volumeIcons[1]
        }
        if (volume < 0.66) {
            return volumeIcons[2]
        }
        return volumeIcons[3]
    }
    
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume
    @Published var volumeIcon: String = volumeIcons[0]
    
    // Audio session object
    private let session = AVAudioSession.sharedInstance()
    
    // Observer
    private var progressObserver: NSKeyValueObservation!
    
    func subscribe() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            self.volumeIcon = getVolumeIcon(volume: session.outputVolume)
        } catch {
            print("cannot activate session")
        }
        
        progressObserver = session.observe(\.outputVolume) { [self] (session, value) in
            DispatchQueue.main.async {
                self.volume = session.outputVolume
                self.volumeIcon = self.getVolumeIcon(volume: session.outputVolume)
            }
        }
    }
    
    func unsubscribe() {
        self.progressObserver.invalidate()
    }
    
    init() {
        subscribe()
    }
}
