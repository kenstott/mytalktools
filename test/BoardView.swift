//
//  ContentView.swift
//  test
//
//  Created by Kenneth Stott on 12/30/22.
//

import SwiftUI
import FMDB
import AVFAudio

struct BoardView: View {
    
    @EnvironmentObject var globalState: GlobalState
    let padding = 0.0
    private var id: Int = 0
    private var geometry: GeometryProxy;
    @StateObject private var board = Board()
    @AppStorage("MaximumRows") var maximumRows = 1
    @State private var isActive = false
    @State private var activeChildBoard: Int? = 0
    @State private var player: AVAudioPlayer?
    @State var rowsToDisplay = 0
    @State var cellWidth = 0.0
    @State var columns = Array<GridItem>(repeating: GridItem(.flexible(), spacing: 0), count: 1)
    @State private var showSharingActionSheet = false
    private var settings = UserDefaults.standard.dictionaryRepresentation()
    
    init(_ id: Int = 1, geometry: GeometryProxy) {
        self.id = id
        self.geometry = geometry
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
                            maximumCellHeight: .constant(Double(geometry.size.height - 50 - (globalState.authorMode ? 40 : 0)) / Double(min(maximumRows, board.rows))),
                            cellWidth: .constant((geometry.size.width / Double(board.columns == 0 ? 1 : board.columns))), board: .constant(board))
                    }
                }
                .frame(width: geometry.size.width)
                .padding(0)
            }
            .frame(minHeight: UIScreen.main.bounds.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - (globalState.authorMode ? 40 : 0), maxHeight: UIScreen.main.bounds.height -
                   geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 50 - (globalState.authorMode ? 40 : 0))
            .fixedSize()
            .onAppear() {
                board.setId(id)
                columns = Array<GridItem>(repeating: GridItem(.flexible(), spacing: 0), count: board.columns)
            }
        }
        .navigationBarTitle(board.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(globalState.authorMode ? "Done" : "Author") {
                    print("Author button tapped!")
                    self.globalState.authorMode.toggle()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if (self.globalState.authorMode) {
                    Button {
                        print("Help")
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                    SharingDialog(board: board)
                    Button {
                        print("Library")
                    } label: {
                        Label("Library", systemImage: "building.columns")
                    }
                    Button {
                        print("Search")
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    Button {
                        print("Type")
                    } label: {
                        Label("Type", systemImage: "keyboard")
                    }
                    Button {
                        print("Wizard")
                    } label: {
                        Label("Wizard", systemImage: "sparkle.magnifyingglass")
                    }
                    Toggle("Edit", isOn: $globalState.editMode)
                    Button {
                        print("Sync")
                    } label: {
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
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

