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
    
    @StateObject private var globalState: GlobalState = GlobalState();
    @ObservedObject var appState = AppState()
    
    init() {
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(globalState)
                .environmentObject(appState)
            ;
        }
    }
}