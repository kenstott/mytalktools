//
//  LibraryView.swift
//  test
//
//  Created by Kenneth Stott on 3/5/23.
//

import SwiftUI
import AVKit

enum Filter {
    case image, sound, video, board, all
}
struct LibraryView: View {
    
    @StateObject private var library: Library
    @Environment(\.editMode) private var editMode
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var boardState: BoardState
    
    @State var root: LibraryRoot
    @State var player = AVPlayer()
    @State var query = ""
    @State var filter: Filter = .all
    @State var selectMode = false
    @MainActor @State var searchResults: [LibraryItem] = []
    @State var searchTask: Task<[LibraryItem], Error>?
    @Binding var selectedURL: String
    private var done: () -> Void?
    
    init(selectMode: Bool, query: String, filter: Filter, root: LibraryRoot, username: String, selectedURL: Binding<String>, done: @escaping () -> Void) {
        _root = State(initialValue: root)
        _filter = State(initialValue: filter)
        _query = State(initialValue: query)
        _selectMode = State(initialValue: selectMode)
        _library = StateObject(wrappedValue: Library(root, username: username))
        _selectedURL = Binding(projectedValue: selectedURL)
        self.done = done
    }
    
    func fixName(_ name: String) -> String {
        switch name {
        case "symbolstix library-": return "Symbolstix"
        default:
            return name
        }
    }
    
    func fuzzyMatch(items: [LibraryItem], searchText: String) throws -> [LibraryItem] {
        try items.filter {
            try Task.checkCancellation()
            return (
                filter == .all ||
                $0.ItemType == 3 && filter == .board ||
                $0.ItemType == 1 && (filter == .sound || filter == .video) ||
                $0.ItemType == 2 && filter == .image
            ) &&
            ($0.OriginalFilename.localizedCaseInsensitiveContains(searchText) ||
             $0.TagString.localizedCaseInsensitiveContains(searchText) ||
             $0.Content?.Text.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    func search(query: String) {
        Task {
            while !library.loaded {
                try await Task.sleep(for: .seconds(1))
            }
            searchTask?.cancel()
            let task = Task.detached {
                try await Task.sleep(nanoseconds: 1500)
                return try await fuzzyMatch(items: library.items ?? [], searchText: query)
            }
            searchTask = task
            searchResults = try await task.value
        }
    }
    
    var body: some View {
        
        return GeometryReader { geo in
            ZStack {
                List {
                    ForEach(searchResults, id: \.self) { row in
                        NavigationLink {
                            switch row.ItemType {
                            case 1:
                                VideoPlayer(player: player)
                                    .onAppear() {
                                        player = AVPlayer(url: URL(string: row.MediaUrl ?? "")!)
                                    }
                                    .navigationTitle(Library.cleanseFilename(row.OriginalFilename))
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar {
                                        ToolbarItem {
                                            Button {
                                                selectedURL = row.MediaUrl!
                                                done()
                                            } label: {
                                                Label(LocalizedStringKey("Select"), systemImage: "checkmark.circle.fill")
                                            }
                                            .disabled(selectMode == false)
                                        }
                                    }
                            case 2:
                                AsyncImage(url: URL(string: row.MediaUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .navigationTitle(Library.cleanseFilename(row.OriginalFilename))
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem {
                                        Button {
                                            selectedURL = row.MediaUrl!
                                            done()
                                        } label: {
                                            Label(LocalizedStringKey("Select"), systemImage: "checkmark.circle.fill").labelStyle(.titleAndIcon)
                                        }
                                        .disabled(selectMode == false)
                                    }
                                }
                            case 3:
                                
                                ContentView(
                                    .constant(Content().copyLibraryContent(row.Content)),
                                    selectMode: selectMode,
                                    onClick: { () -> Void in
                                        
                                    },
                                    maximumCellHeight: .constant(geo.size.height),
                                    cellWidth: .constant(geo.size.width),
                                    board: .constant(Board()),
                                    refresh: 0,
                                    zoomHeight: 250.0,
                                    zoomWidth: 250.0
                                )
                                
                            default:
                                EmptyView().navigationTitle(Library.cleanseFilename(row.OriginalFilename))
                            }
                        } label: {
                            HStack {
                                switch row.ItemType {
                                case 1:
                                    switch URL(string: row.MediaUrl ?? "")?.pathExtension {
                                    case "mov": Image(systemName: "film").frame(width: 50.0, height: 50.0)
                                    case "3gp": Image(systemName: "film").frame(width: 50.0, height: 50.0)
                                    case "mp4": Image(systemName: "film").frame(width: 50.0, height: 50.0)
                                    default: Image(systemName: "music.note").frame(width: 50.0, height: 50.0)
                                    }
                                case 2:
                                    VStack {
                                        AsyncImage(url: URL(string: row.MediaUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    .frame(width: 50.0, height: 50.0)
                                case 3:
                                    VStack {
                                        AsyncImage(url: URL(string: row.Content?.Picture ?? "")) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        Text(row.Content?.Text ?? "").font(.system(size: 10))
                                    }.frame(width: 50.0, height: 50.0)
                                default:
                                    EmptyView().frame(width: 50.0, height: 50.0)
                                }
                                VStack(alignment: .leading) {
                                    Text(Library.cleanseFilename(row.Content != nil ? row.Content?.Text ?? "" : row.OriginalFilename)).font(.system(size: 25))
                                    Text(row.TagString).font(.system(size: 20))
                                }
                            }
                        }
                        .swipeActions {
                            
                            if editMode?.wrappedValue.isEditing == false {
                                Button {
                                    print("Copy")
                                } label: {
                                    Label(LocalizedStringKey("Copy"), systemImage: "doc.on.doc")
                                }
                                .tint(.gray)
                                
                                Button {
                                    print("Share")
                                } label: {
                                    Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up.circle")
                                }
                                .tint(.blue)
                                
                                Button {
                                    print("Download")
                                } label: {
                                    Label(LocalizedStringKey("Download"), systemImage: "square.and.arrow.down")
                                }
                                .tint(.green)
                            }
                            
                            if library.rights.create && editMode?.wrappedValue.isEditing == true {
                                Button {
                                    print("Tag")
                                } label: {
                                    Label(LocalizedStringKey("Tag"), systemImage: "tag")
                                }
                                .tint(.cyan)
                                Button {
                                    print("Delete")
                                } label: {
                                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            
                        }
                        .deleteDisabled(false)
                    }.onDelete {
                        indexSet in print(indexSet)
                    }
                }
                .task {
                    if !library.loaded {
                        library.getLibraryItems()
                    }
                }
                .navigationTitle(fixName(root.Name))
                .searchable(text: $query)
                .onAppear {
                    boardState.editMode = false
                    if query != "" {
                        search(query: query)
                    }
                }
                .onChange(of: query) {
                    newQuery in
                    search(query: newQuery)
                }
                .toolbar {
                    ToolbarItemGroup {
                        if library.rights.delete || library.rights.update {
                            EditButton()
                        }
                        if library.rights.create && editMode?.wrappedValue.isEditing == true {
                            Button {
                                print("Create")
                            } label: {
                                Label(LocalizedStringKey("Add"), systemImage: "plus")
                            }
                        }
                    }
                }
                if library.loaded == false {
                    ProgressView("Loading Library")
                }
            }
        }
        
    }
}
