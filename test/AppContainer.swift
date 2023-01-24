//
//  ContentView.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB
import AVFAudio

struct AppContainer: View {
    
    @EnvironmentObject var globalState: BoardState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    
    init() {
        do {
            // Attempts to activate session so you can play audio,
            // if other sessions have priority this will fail
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            // Handle error
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                BoardView(1, geometry: geometry).id(appState.rootViewId)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                globalState.isPortrait = scene.interfaceOrientation.isPortrait
                print("Is portrait: \(globalState.isPortrait)")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct AppContainer_Previews: PreviewProvider {
    static var previews: some View {
        AppContainer().environmentObject(BoardState())
    }
}
