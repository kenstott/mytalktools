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
    
    @EnvironmentObject var globalState: GlobalState
    @EnvironmentObject var appState: AppState
    let padding = 0.0
    private var id: Int = 0
    private var geometry: GeometryProxy;
    @Environment(\.dismiss) var dismiss
    @StateObject private var board = Board()
    @AppStorage("MaximumRows") var maximumRows = 1
    @AppStorage("ForegroundColor") var foregroundColor = "Black"
    @AppStorage("AdvancedUserBar") var advancedUseBar = false
    @AppStorage("UserHints") var userHints = true
    @AppStorage("UserBarSync") var userBarSync = false
    @AppStorage("UserBarWizard") var userBarWizard = false
    @AppStorage("VolumeButton") var volumeButton = true
    @State private var isActive = false
    @State private var activeChildBoard: Int? = 0
    @State private var player: AVAudioPlayer?
    @State var rowsToDisplay = 0
    @State var cellWidth = 0.0
    @State var showHelp = false
    @State var columns = Array<GridItem>(repeating: GridItem(.flexible(), spacing: 0), count: 1)
    @State private var showSharingActionSheet = false
    @State var showVolume = false
    private var settings = UserDefaults.standard.dictionaryRepresentation()
    
    init(_ id: Int = 1, geometry: GeometryProxy) {
        self.id = id
        self.geometry = geometry
    }
    
    func toolbarShown() -> CGFloat {
        return globalState.authorMode || advancedUseBar ? 40 : 0
    }
    
    var body: some View {
        ZStack {
            ForEach(board.content, id: \.id) {
                item in
                if item.childBoardId != 0 {
                    NavigationLink(destination: BoardView(item.childBoardId, geometry: geometry), tag: item.childBoardId, selection: $activeChildBoard) { EmptyView() }
                }
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(board.content, id: \.id) {
                        item in
                        ContentView(
                            item.id,
                            onClick: { () -> Void in
                                if (item.childBoardId != 0) {
                                    activeChildBoard = item.childBoardId
                                }
                            },
                            maximumCellHeight: .constant(Double(geometry.size.height - 50 - toolbarShown()) / Double(min(maximumRows, board.rows))),
                            cellWidth: .constant((geometry.size.width / Double(board.columns == 0 ? 1 : board.columns))), board: .constant(board))
                    }
                }
                .frame(width: geometry.size.width)
                .padding(0)
            }
            .frame(minHeight: UIScreen.main.bounds.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - toolbarShown(), maxHeight: UIScreen.main.bounds.height -
                   geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - toolbarShown())
            .fixedSize()
            .onAppear() {
                board.setId(id)
                columns = Array<GridItem>(repeating: GridItem(.flexible(), spacing: 0), count: board.columns)
            }
            
        }
        .toast(isPresenting: $showHelp, alert: {
            AlertToast(type: .regular, title: "Tap 'Edit' to begin editing")
        })
        .navigationBarTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVolume) {
            VolumeDialog().presentationDetents([.medium])
        }
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
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
            ToolbarItem(placement: .primaryAction) {
                Button(globalState.authorMode ? LocalizedStringKey("Done") : LocalizedStringKey("Author")) {
                    print("Author button tapped!")
                    self.globalState.authorMode.toggle()
                    if userHints && globalState.authorMode && !globalState.editMode {
                        showHelp.toggle()
                    }
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if (self.globalState.authorMode) {
                    Button {
                        print("Help")
                    } label: {
                        Label(LocalizedStringKey("Help"), systemImage: "questionmark.circle")
                    }
                    SharingDialog(board: board)
                    Button {
                        print("Library")
                    } label: {
                        Label(LocalizedStringKey("Library"), systemImage: "building.columns")
                    }
                    Button {
                        print("Search")
                    } label: {
                        Label(LocalizedStringKey("Search"), systemImage: "magnifyingglass")
                    }
                    Button {
                        print("Undo")
                    } label: {
                        Label(LocalizedStringKey("Undo"), systemImage: "arrow.uturn.backward")
                    }
                    Button {
                        print("Redo")
                    } label: {
                        Label(LocalizedStringKey("Redo"), systemImage: "arrow.uturn.forward")
                    }
                    Toggle(LocalizedStringKey("Edit"), isOn: $globalState.editMode)
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


struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            BoardView(1, geometry: geometry).environmentObject(GlobalState())
        }
    }
}

