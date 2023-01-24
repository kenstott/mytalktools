//
//  testApp.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB

var appDefaults = [
    "ForegroundColor": "Black",
    "BackgroundColor": "White",
    "DefaultFontSize": "12",
    "SeparatorLines": true,
    "MaximumRows": 3
] as [String : Any]


@main
struct testApp: App {
    
    @StateObject private var globalState: BoardState = BoardState();
    @ObservedObject var appState = AppState()
    @ObservedObject var speak = Speak()
    @ObservedObject var media = Media()
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    
    init() {
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(globalState)
                .environmentObject(appState)
                .environmentObject(speak)
                .environmentObject(media)
        }
        
    }
}
