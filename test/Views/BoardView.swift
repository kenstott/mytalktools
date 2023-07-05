//
//  BoardView.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB
import AlertToast
import AVFAudio
import Contacts
import CoreSpotlight

struct BoardView: View {
    
    @EnvironmentObject var boardState: BoardState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var media: Media
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var userState: User
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var volume: VolumeObserver
    @EnvironmentObject var scheduleMonitor: ScheduleMonitor
    
    let padding = 0.0
    private var id: UInt = 0
    private var geometry: GeometryProxy;
    @Environment(\.dismiss) var dismiss
    @StateObject private var board = Board()
    @AppStorage("MaximumRows") var maximumRows = 1
    @AppStorage("ForegroundColor") var foregroundColor = "Black"
    @AppStorage("AdvancedUserBar") var advancedUseBar = false
    @AppStorage("UserHints") var userHints = true
    @AppStorage("AuthorHints") var authorHints = true
    @AppStorage("DisplayAsList") var displayAsList = false
    @AppStorage("UserBarSync") var userBarSync = false
    @AppStorage("UserBarSettings") var userBarSettings = true
    @AppStorage("UserBarWizard") var userBarWizard = false
    @AppStorage("VolumeButton") var volumeButton = true
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("BoardName") var storedBoardName = ""
    @AppStorage("PhraseMode") var phraseMode = "0"
    @AppStorage("AuthoringAllowed") var authoringAllowed = true
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    
    @State private var isActive = false
    @State private var activeChildBoard: UInt? = 0
    @State private var scheduleChildBoard: UInt? = 0
    @State private var player: AVAudioPlayer?
    @State var rowsToDisplay = 0
    @State private var showSharingActionSheet = false
    @State var showVolume = false
    @State var showAuthorHelp = false
    @State var showUserHelp = false
    @State var showTypePhrase = false
    @State var showSync = false
    @State var newDatabase = 0
    @State private var contact = CNContact()
    @State private var showContacts = false
    @State private var enteredRegion: UInt = 0
    @State private var showLocationBasedBoard = false
    @State private var showSpotlightSearchBoard = false
    @State private var spotlightSearchBoard: UInt = 0
    @State private var showLogin = false
    
    var maximumCellHeight: Double { get { Double(geometry.size.height - 50 - toolbarShown - phraseBarShown) / Double(min(maximumRows, board.rows)) } }
    var cellWidth: Double { get { geometry.size.width / Double(board.columns == 0 ? 1 : board.columns) } }
    var toolbarShown: CGFloat { get { boardState.authorMode || advancedUseBar ? 40 : 0 } }
    var phraseBarShown: CGFloat { get { phraseMode == "1" || phraseBarState.userPhraseModeToggle ? 100 : 0 } }
    var columns: Array<GridItem> { get { Array<GridItem>(
        repeating: GridItem(.fixed(cellWidth), spacing: 0, alignment: .leading),
        count: max(board.columns, 1)) } }
    func multiplier(_ content: Content) -> Double {
        return 1
    }
    
    init(_ id: UInt = 1, geometry: GeometryProxy) {
        self.id = id
        self.geometry = geometry
    }
    
    var body: some View {
        let phraseBarView = PhraseBarView()
        let regionMonitor = RegionMonitor(enteredRegion: $enteredRegion)
        return ZStack {
            VStack {
                if media.downloading {
                    ProgressView(value: media.fileLoadingProgress, total: 1.0)
                }
                if media.uploading {
                    ProgressView(value: media.fileLoadingProgress, total: 1.0).tint(.white)
                        .background(.black)
                }
                switch boardState.state {
                case .closed:
                    ProgressView("Downloading your communication board...").onAppear {
                        Task {
                            await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                            _ = board.setId(id, storedUsername, storedBoardName, boardState)
                            Task {
                                regionMonitor.startMonitor()
                            }
                        }
                    }
                case .ready:
                    VStack {
                        if phraseMode == "1" || phraseBarState.userPhraseModeToggle {
                            phraseBarView
                        }
                        ForEach($board.contents, id: \.id) {
                            $item in
                            if $item.childBoardId.wrappedValue != 0 {
                                NavigationLink(destination: BoardView(item.linkId, geometry: geometry), tag: item.linkId, selection: $activeChildBoard)
                                {
                                    EmptyView()
                                }
                            }
                        }
                        NavigationLink(destination: BoardView(SpecialBoardType.MostRecent.rawValue, geometry: geometry), tag: SpecialBoardType.MostRecent.rawValue, selection: $activeChildBoard) {
                            EmptyView()
                        }
                        NavigationLink(destination: BoardView(SpecialBoardType.MostUsed.rawValue, geometry: geometry), tag: SpecialBoardType.MostUsed.rawValue, selection: $activeChildBoard) {
                            EmptyView()
                        }
                        if scheduleMonitor.boardId != 0 {
                            NavigationLink(destination: BoardView(scheduleMonitor.boardId ?? 0, geometry: geometry), tag: scheduleMonitor.boardId ?? 0, selection: $scheduleChildBoard)
                            {
                                EmptyView()
                            }
                        }
                        if (displayAsList) {
                            List($board.contents) {
                                $item in
                                ContentView(
                                    $item,
                                    selectMode: false,
                                    onClick: { () -> Void in
                                        if (item.link != 0) {
                                            activeChildBoard = item.linkId
                                        }
                                    },
                                    maximumCellHeight: .constant(maximumCellHeight),
                                    cellWidth: .constant(0),
                                    board: .constant(self.board),
                                    refresh: newDatabase,
                                    zoomHeight: Double(geometry.size.height) - 40.0,
                                    zoomWidth: Double(geometry.size.width)
                                )
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 0) {
                                    ForEach($board.filteredContents, id: \.id) {
                                        $item in
                                        ContentView(
                                            $item,
                                            selectMode: false,
                                            onClick: { () -> Void in
                                                switch item.contentType {
                                                case .goBack: dismiss()
                                                case .goHome: appState.rootViewId = UUID()
                                                default:
                                                    DispatchQueue.main.async {
                                                        boardState.updateUsage(item, storedUsername, storedBoardName)
                                                        boardState.updateMru(item, storedUsername, storedBoardName)
                                                        if (item.linkId != 0) {
                                                            activeChildBoard = item.linkId
                                                        }
                                                    }
                                                }
                                            },
                                            maximumCellHeight: .constant(maximumCellHeight),
                                            cellWidth: .constant(cellWidth * Double(item.cellSize)),
                                            board: .constant(self.board),
                                            refresh: newDatabase,
                                            zoomHeight: Double(geometry.size.height) - 40.0,
                                            zoomWidth: Double(geometry.size.width)
                                        )
                                        if item.cellSize > 1 { Color.clear }
                                    }
                                }
                                .frame(width: geometry.size.width)
                                .padding(0)
                            }
                            .frame(minHeight: UIScreen.main.bounds.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - toolbarShown - phraseBarShown, maxHeight: UIScreen.main.bounds.height -
                                   geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - toolbarShown - phraseBarShown)
                            .fixedSize()
                        }
                    }
                    .toast(isPresenting: $showAuthorHelp, alert: {
                        AlertToast(type: .regular, title: "Tap 'Edit' to begin editing")
                    })
                    .navigationBarTitle(board.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .confirmationDialog("Synchronize with Workspace", isPresented: $showSync) {
                        Button("Overwrite Local Device") {
                            Task {
                                await boardState.overwriteDevice(dbUser: boardState.dbUrl!, username: userState.username, media: media, boardID: storedBoardName)
                                DispatchQueue.main.async {
                                    boardState.reloadDatabase(fileURL: boardState.dbUrl!)
                                    newDatabase = newDatabase + 1
                                    appState.rootViewId = UUID()
                                }
                            }
                        }
                        Button("Overwrite Remote Workspace") {
                            
                        }
                        Button("Merge Local Device and Remote Workspace") {
                            Task {
                                await boardState.merge(username: userState.username, boardID: storedBoardName, media: media)
                                DispatchQueue.main.async {
                                    boardState.reloadDatabase(fileURL: boardState.dbUrl!)
                                    newDatabase = newDatabase + 1
                                    appState.rootViewId = UUID()
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showTypePhrase) {
                        TypePhrase(done: {
                            phrase in
                            print(phrase)
                            showTypePhrase = false
                        }, cancel: {  showTypePhrase = false })
                    }
                    .sheet(isPresented: $showVolume) {
                        VolumeDialog().presentationDetents([.medium])
                    }
                    .sheet(isPresented: $showContacts) {
                        EmbeddedContactPicker(contact: $contact, selectionPredicate: NSPredicate(format: "givenName == %@", argumentArray: [UUID()]))
                        //                }.sheet(isPresented: $showLocationBasedBoard) {
                        //                    NavigationView {
                        //                        BoardView(enteredRegion, geometry: geometry)
                        //                    }
                    }.sheet(isPresented: $showSpotlightSearchBoard) {
                        NavigationView {
                            BoardView(spotlightSearchBoard, geometry: geometry)
                        }
                    }
                    .sheet(isPresented: $showLogin) {
                        Author()
                    }
                    .onAppear {
                        showAuthorHelp = boardState.authorMode && authorHints && !boardState.editMode
                        showUserHelp = !boardState.authorMode && userHints
                        
                        _ = board.setId(id, storedUsername, storedBoardName, boardState)
                        scheduleMonitor.createSchedule()
                        Task {
                            regionMonitor.startMonitor()
                            speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                                print("Done")
                            }
                        }
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                        
                    }
                    .toolbar {
                        if authoringAllowed {
                            ToolbarItem(placement: .primaryAction) {
                                if !boardState.authorMode {
                                    Button {
                                        showLogin = true
                                    } label: {
                                        Text( LocalizedStringKey("Author"))
                                    }
                                } else {
                                    Button( LocalizedStringKey("Done")) {
                                        self.boardState.authorMode.toggle()
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .automatic) {
                            if (volumeButton) {
                                Button {
                                    //                                print("Volume")
                                    showVolume.toggle()
                                } label: {
                                    Label(LocalizedStringKey("Volume"), systemImage: volume.volumeIcon)
                                }
                            } else {
                                EmptyView()
                            }
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            if (self.boardState.authorMode) {
                                Button {
                                    print("Help")
                                } label: {
                                    Label(LocalizedStringKey("Help"), systemImage: "questionmark.circle")
                                }
                                SharingDialog(board: board)
                                LibraryDialog().environmentObject(userState)
                                Button {
                                    print("Search")
                                } label: {
                                    Label(LocalizedStringKey("Search"), systemImage: "magnifyingglass")
                                }
                                Button {
                                    boardState.undo()
                                    Task {
                                        await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                                        _ = board.setId(id, storedUsername, storedBoardName, boardState)
                                    }
                                    //                                print("Undo")
                                } label: {
                                    Label(LocalizedStringKey("Undo"), systemImage: "arrow.uturn.backward")
                                }.disabled(!boardState.undoable || !boardState.editMode)
                                Button {
                                    boardState.redo()
                                    Task {
                                        await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                                        _ = board.setId(id, storedUsername, storedBoardName, boardState)
                                    }
                                    //                                print("Redo")
                                } label: {
                                    Label(LocalizedStringKey("Redo"), systemImage: "arrow.uturn.forward")
                                }.disabled(!boardState.redoable || !boardState.editMode)
                                Toggle(LocalizedStringKey("Edit"), isOn: $boardState.editMode)
                                Button {
                                    //                                print("Sync")
                                    showSync = true
                                } label: {
                                    Label(LocalizedStringKey("Sync"), systemImage: "arrow.triangle.2.circlepath")
                                }
                                
                            } else if (advancedUseBar) {
                                Button {
                                    //                                print("Home")
                                    appState.rootViewId = UUID()
                                } label: {
                                    Label(LocalizedStringKey("Home"), systemImage: "house")
                                }
                                Button {
                                    //                                print("Back")
                                    dismiss()
                                } label: {
                                    Label(LocalizedStringKey("Back"), systemImage: "arrowshape.turn.up.backward")
                                }
                                if userBarSettings {
                                    Button {
                                        //                                    print("Settings")
                                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                                        }
                                    } label: {
                                        Label(LocalizedStringKey("Sync"), systemImage: "gearshape")
                                    }
                                }
                                if userBarSync {
                                    Button {
                                        //                                    print("Sync")
                                        showSync = true
                                    } label: {
                                        Label(LocalizedStringKey("Sync"), systemImage: "arrow.triangle.2.circlepath")
                                    }
                                }
                                Button {
                                    showTypePhrase = true
                                } label: {
                                    Label("Type Words", systemImage: "keyboard")
                                }
                                Button {
                                    print("Recents")
                                    activeChildBoard = SpecialBoardType.MostRecent.rawValue
                                } label: {
                                    Label(LocalizedStringKey("Recents"), systemImage: "clock")
                                }
                                Button {
                                    print("Most Viewed")
                                    activeChildBoard = SpecialBoardType.MostUsed.rawValue
                                } label: {
                                    Label(LocalizedStringKey("Most Viewed"), systemImage: "list.number")
                                }
                                if (userBarWizard) {
                                    Button {
                                        print("Wizard")
                                    } label: {
                                        Label("Wizard", systemImage: "sparkle.magnifyingglass")
                                    }
                                }
                            }
                        }
                    }
                    regionMonitor
                }
            }
            .onChange(of: scheduleMonitor.boardId) { newValue in
                Task {
                    if newValue != 0 {
                        scheduleChildBoard = scheduleMonitor.boardId
                    }
                }
            }
            .onChange(of: enteredRegion) { newValue in
                if enteredRegion != 0 {
                    showLocationBasedBoard = true
                }
            }
            .onChange(of: [ttsVoice, ttsVoiceAlternate]) {
                newValue in
                Task {
                    speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                        print("Downloaded speech files")
                    }
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    let items = identifier.split(separator: ":")
                    if items.count == 2 && items[0] == storedUsername {
                        let c = Content().setId(Int(items[1]) ?? 0)
                        spotlightSearchBoard = UInt(c.boardId)
                        showSpotlightSearchBoard = true
                    }
                }
            }
            .onOpenURL { url in
                //            print(url)
                let command = url.absoluteString
                    .replacingOccurrences(of: "mytalktools://", with: "")
                    .replacingOccurrences(of: "mytalktools:/", with: "")
                    .replacingOccurrences(of: "mtt://", with: "")
                    .replacingOccurrences(of: "mtt:/", with: "")
                    .split(separator: "/")
                switch(command[0]) {
                case "board":
                    if command.count == 2 {
                        spotlightSearchBoard = UInt(command[1]) ?? 0
                        showSpotlightSearchBoard = true
                    }
                case "contacts:":
                    showContacts = true
                case "home": appState.rootViewId = UUID()
                case "back": dismiss()
                case "type": showTypePhrase = true
                case "phraseBarOn": phraseBarState.userPhraseModeToggle = true
                case "phraseBarOff": phraseBarState.userPhraseModeToggle = false
                case "phraseBarToggle": phraseBarState.userPhraseModeToggle = !phraseBarState.userPhraseModeToggle
                case "phraseBarClear": phraseBarState.contents.removeAll()
                case "phraseBarBackspace": phraseBarState.contents.removeLast()
                case "play": phraseBarState.speakPhrases()
                default: print("Unknown command: \(url.absoluteString)")
                }
            }
            if speak.loadingSpeechFiles {
                ProgressView("Downloading voices...")
                    .padding(8)
                    .cornerRadius(5)
                    .background(.white)
            }
        }
    }
}



struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            BoardView(1, geometry: geometry).environmentObject(BoardState())
        }
    }
}

