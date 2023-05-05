//
//  ContentView.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB
import AlertToast
import AVFAudio

struct BoardView: View {
    
    @EnvironmentObject var boardState: BoardState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var media: Media
    @EnvironmentObject var phraseBarState: PhraseBarState
    @EnvironmentObject var userState: User
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
    @AppStorage("UserBarWizard") var userBarWizard = false
    @AppStorage("VolumeButton") var volumeButton = true
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("BoardName") var storedBoardName = ""
    @AppStorage("PhraseMode") var phraseMode = "0"
    @State private var isActive = false
    @State private var activeChildBoard: UInt? = 0
    @State private var player: AVAudioPlayer?
    @State var rowsToDisplay = 0
    @State private var showSharingActionSheet = false
    @State var showVolume = false
    @State var showAuthorHelp = false
    @State var showUserHelp = false
    var maximumCellHeight: Double { get { Double(geometry.size.height - 50 - toolbarShown - phraseBarShown) / Double(min(maximumRows, board.rows)) } }
    var cellWidth: Double { get { geometry.size.width / Double(board.columns == 0 ? 1 : board.columns) } }
    var toolbarShown: CGFloat { get { boardState.authorMode || advancedUseBar ? 40 : 0 } }
    var phraseBarShown: CGFloat { get { phraseMode == "1" ? 100 : 0 } }
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
        VStack {
            if media.downloading {
                ProgressView(value: media.fileLoadingProgress, total: 1.0)
            }
            switch boardState.state {
            case .closed:
                ProgressView("Downloading your communication board...").onAppear {
                    Task {
                        await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                        _ = board.setId(id)
                    }
                }
            case .ready:
                VStack {
                    if phraseMode == "1" {
                        PhraseBarView()
                    }
                    ForEach($board.contents, id: \.id) {
                        $item in
                        if $item.childBoardId.wrappedValue != 0 {
                            NavigationLink(destination: BoardView(item.linkId, geometry: geometry), tag: item.linkId, selection: $activeChildBoard) { EmptyView() }
                        }
                    }
                    if (displayAsList) {
                        List($board.contents) {
                            $item in
                            ContentView(
                                $item,
                                onClick: { () -> Void in
                                    if (item.link != 0) {
                                        activeChildBoard = item.linkId
                                    }
                                },
                                maximumCellHeight: .constant(maximumCellHeight),
                                cellWidth: .constant(0),
                                board: .constant(self.board)
                            )
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach($board.filteredContents, id: \.id) {
                                    $item in
                                    ContentView(
                                        $item,
                                        onClick: { () -> Void in
                                            switch item.contentType {
                                            case .goBack: dismiss()
                                            case .goHome: appState.rootViewId = UUID()
                                            default:
                                                if (item.linkId != 0) {
                                                    activeChildBoard = item.linkId
                                                }
                                            }
                                        },
                                        maximumCellHeight: .constant(maximumCellHeight),
                                        cellWidth: .constant(cellWidth * Double(item.cellSize)),
                                        board: .constant(self.board)
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
                .sheet(isPresented: $showVolume) {
                    VolumeDialog().presentationDetents([.medium])
                }
                .onAppear {
                    showAuthorHelp = boardState.authorMode && authorHints
                    showUserHelp = !boardState.authorMode && userHints
                   
                        _ = board.setId(id)
                    
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        if !boardState.authorMode {
                            Button {
                                
                            } label: {
                                NavigationLink(destination: Author()) { Text( LocalizedStringKey("Author"))
                                }
                            }
                        } else {
                            Button( LocalizedStringKey("Done")) {
                                print("Done button tapped!")
                                self.boardState.authorMode.toggle()
                            }
                        }
                    }
                    ToolbarItem(placement: .automatic) {
                        if (volumeButton) {
                            Button {
                                print("Volume")
                                showVolume.toggle()
                            } label: {
                                Label(LocalizedStringKey("Volume"), systemImage: "speaker.wave.1")
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
                                    _ = board.setId(id)
                                }
                                print("Undo")
                            } label: {
                                Label(LocalizedStringKey("Undo"), systemImage: "arrow.uturn.backward")
                            }.disabled(!boardState.undoable)
                            Button {
                                boardState.redo()
                                Task {
                                    await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                                    _ = board.setId(id)
                                }
                                print("Redo")
                            } label: {
                                Label(LocalizedStringKey("Redo"), systemImage: "arrow.uturn.forward")
                            }.disabled(!boardState.redoable)
                            Toggle(LocalizedStringKey("Edit"), isOn: $boardState.editMode)
                            Button {
                                print("Sync")
                            } label: {
                                Label(LocalizedStringKey("Sync"), systemImage: "arrow.triangle.2.circlepath")
                            }
                            
                        } else if (advancedUseBar) {
                            Button {
                                print("Home")
                                appState.rootViewId = UUID()
                            } label: {
                                Label(LocalizedStringKey("Home"), systemImage: "house")
                            }
                            Button {
                                print("Back")
                                dismiss()
                            } label: {
                                Label(LocalizedStringKey("Back"), systemImage: "arrowshape.turn.up.backward")
                            }
                            if (userBarSync) {
                                Button {
                                    print("Sync")
                                } label: {
                                    Label(LocalizedStringKey("Sync"), systemImage: "arrow.triangle.2.circlepath")
                                }
                            }
                            Button {
                                print("Type Words")
                            } label: {
                                Label("Type Words", systemImage: "keyboard")
                            }
                            Button {
                                print("Recents")
                            } label: {
                                Label(LocalizedStringKey("Recents"), systemImage: "clock")
                            }
                            Button {
                                print("Most Viewed")
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

