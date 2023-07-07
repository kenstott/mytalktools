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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var userState: User
    @EnvironmentObject var globalState: BoardState
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
    @EnvironmentObject var volume: VolumeObserver
    @EnvironmentObject var scheduleMonitor: ScheduleMonitor
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("SwipeDirectoryAuthor") var authorModeDirectory = true
    @AppStorage("SwipeDirectoryUser") var userModeDirectory = true
    @State var query = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if horizontalSizeClass != .compact && (( authorModeDirectory && globalState.authorMode ) || userModeDirectory) {
                    NavigationView {
                        List {
                            OutlineGroup(globalState.boardTreeFiltered, children: \.filteredChildren) { item in
                                ContentListRow(Content().setId(item.id), defaultFontSize: 0, foregroundColor: Color.black, disclosureIndicator: false)
                                    .onTapGesture {
                                        if globalState.directNavigateBoard != item.parentBoard {
                                            globalState.directNavigateBoard = item.parentBoard
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        .searchable(text: $query)
                        .onChange(of: query) { newValue in
                            Task {
                                globalState.boardTreeSearch = query
                            }
                        }
                        BoardView(1, geometry: geometry).id(appState.rootViewId)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                        globalState.isPortrait = scene.interfaceOrientation.isPortrait
                    }
                    .navigationViewStyle(DoubleColumnNavigationViewStyle())
                } else {
                    NavigationView {
                        BoardView(1, geometry: geometry).id(appState.rootViewId)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                        globalState.isPortrait = scene.interfaceOrientation.isPortrait
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }
    }
}

struct AppContainer_Previews: PreviewProvider {
    static var previews: some View {
        AppContainer().environmentObject(BoardState())
    }
}
