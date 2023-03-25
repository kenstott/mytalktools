//
//  LibraryView.swift
//  test
//
//  Created by Kenneth Stott on 3/5/23.
//

import SwiftUI
import AVKit

struct LibraryView: View {
    
    @State var root: LibraryRoot
    @State var player = AVPlayer()
    @State var query = ""
    @MainActor @State var searchResults: [LibraryItem] = []
    @State var searchTask: Task<[LibraryItem], Error>?
    @ObservedObject var library: Library
    @Environment(\.editMode) private var editMode
    
    init(root: LibraryRoot, username: String) {
        _root = State(initialValue: root)
        self.library = Library(root, username: username)
    }
    
    func fixName(_ name: String) -> String {
        switch name {
        case "symbolstix library-": return "Symbolstix"
        default:
            return name
        }
    }
    
    var body: some View {
        GeometryReader { geo in
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
                        case 2:
                            AsyncImage(url: URL(string: row.MediaUrl ?? "")) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }.navigationTitle(Library.cleanseFilename(row.OriginalFilename))
                        case 3:
                            
                            ContentView(
                                .constant(Content().copyLibraryContent(row.Content)),
                                onClick: { () -> Void in
                                    
                                },
                                maximumCellHeight: .constant(geo.size.height),
                                cellWidth: .constant(geo.size.width),
                                board: .constant(Board())
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
                            case 2: AsyncImage(url: URL(string: row.ThumbnailUrl ?? "")) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }.frame(width: 50.0, height: 50.0)
                            case 3:
                                VStack {
                                    AsyncImage(url: URL(string: row.Content?.Picture ?? "")) { image in
                                        image.resizable().scaledToFit()
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
                library.getLibraryItems()
            }
            .navigationTitle(fixName(root.Name))
            .searchable(text: $query)
            .onChange(of: query) {
                newQuery in
                Task {
                    searchTask?.cancel()
                    let task = Task.detached {
                        try await Task.sleep(for: .seconds(1.5)) // debounce; if you don't want debouncing, remove this, but it can eliminate annoying updates of the UI while the user is typing
                        return try await fuzzyMatch(items: library.items ?? [], searchText: query)
                    }
                    searchTask = task
                    searchResults = try await task.value
                }
            }
            .toolbar {
                if library.rights.delete || library.rights.update {
                    ToolbarItem {
                        EditButton()
                    }
                }
                if library.rights.create && editMode?.wrappedValue.isEditing == true {
                    ToolbarItem {
                        Button {
                            print("Create")
                        } label: {
                            Label(LocalizedStringKey("Add"), systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    
    func fuzzyMatch(items: [LibraryItem], searchText: String) throws -> [LibraryItem] {
        try items.filter {
            try Task.checkCancellation()
            return $0.OriginalFilename.localizedCaseInsensitiveContains(searchText) ||
            $0.TagString.localizedCaseInsensitiveContains(searchText) ||
            $0.Content?.Text.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
}
