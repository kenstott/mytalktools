//
//  testApp.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB
import UserNotifications

var appDefaults = [
    "ForegroundColor": "Black",
    "BackgroundColor": "White",
    "DefaultFontSize": "12",
    "SeparatorLines": true,
    "MaximumRows": 3
] as [String : Any]

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var callback: (Any?) -> Void = { number in}
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        callback(response.notification.request.content.userInfo["boardId"])
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationDelegate = NotificationDelegate()
    
    func setCallback(_ callback: @escaping (Any?) -> Void) {
        self.notificationDelegate.callback = callback
    }
    
    @AppStorage("DefaultRotation") var defaultRotation = "0"
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        switch defaultRotation {
        case "1": return .portrait
        case "2": return .landscape
        default: return .all
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }
}

@main
struct testApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var boardState = BoardState();
    @ObservedObject var appState = AppState()
    @ObservedObject var speak = Speak()
    @ObservedObject var media = Media()
    @ObservedObject var phraseBarState = PhraseBarState()
    @ObservedObject var userState = User()
    @ObservedObject var volumeObserver = VolumeObserver()
    @ObservedObject var scheduleMonitor = ScheduleMonitor()
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    
    init() {
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(boardState)
                .environmentObject(appState)
                .environmentObject(speak)
                .environmentObject(media)
                .environmentObject(phraseBarState)
                .environmentObject(userState)
                .environmentObject(volumeObserver)
                .environmentObject(scheduleMonitor)
                .onAppear {
                    appDelegate.setCallback { number in
                        print("boardId=\(String(describing: number))")
                        scheduleMonitor.boardId = UInt("\(number ?? "0")")
                    }
                }
        }
        
    }
}
