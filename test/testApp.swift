//
//  testApp.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB

@main
struct testApp: App {
    
    @StateObject private var dataWrapper: DataWrapper = DataWrapper();
    
    private var appDefaults = ["MaximumRows": 3]
    
    init() {
        initializeBoard()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer().environmentObject(dataWrapper);
        }
    }
}
