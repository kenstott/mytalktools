//
//  LibraryDialog.swift
//  test
//
//  Created by Kenneth Stott on 3/4/23.
//

import SwiftUI

struct LibraryDialogTable: View {
    @EnvironmentObject var userState: User
    @Environment(\.dismiss) var dismiss
    @State var title: String = "Manage Libraries"
    @State var filter: Filter = .all
    @State var query = ""
    @State var selectMode = false
    @Binding var selectedURL: String
    
    func getLibraryTitle(_ row: LibraryRoot) -> String {
        var title = ""
        var rights = ""
        let sharedLibrary = row.SharedUsers?.first { $0.UserNameorInviteEmail == userState.username} ?? SharedUser()
        
        if sharedLibrary.Create {
            rights = "C\(rights)"
        }
        if sharedLibrary.Read {
            rights = "R\(rights)"
        }
        if sharedLibrary.Update {
            rights = "U\(rights)"
        }
        if sharedLibrary.Delete {
            rights = "D\(rights)"
        }
        
        if row.Name == "submissions" {
            title = "Submissions"
            rights = "CR"
        } else if (row.Name == "symbolstix library-") {
            title = "Symbolstix"
            rights = "R"
        } else if (row.Name == "Public Library" || row.Name == "Aragon Media") {
            title = row.Name
            rights = "R"
        } else {
            title = "\(row.OwnerId)-\(row.Name)"
        }
        title = "\(title) [\(rights)]"
        return title
    }
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text(LocalizedStringKey("My Libraries"))) {
                    ForEach((userState.myLibraries ?? []), id: \.self) { row in
                        NavigationLink(row.Name, destination: LibraryView(selectMode: selectMode, query: query, filter: filter, root: row, username: userState.username, selectedURL: $selectedURL) {
                            dismiss()
                        })
                            .swipeActions {
                                Button {
                                    print("Right on!")
                                } label: {
                                    Label(LocalizedStringKey("Share Library"), systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                    }
                }
                Section(header: Text(LocalizedStringKey("Libraries Shared With Me"))) {
                    ForEach((userState.sharedLibraries ?? []), id: \.self) { row in
                        NavigationLink(getLibraryTitle(row), destination: LibraryView(selectMode: selectMode, query: query, filter: filter, root: row, username: userState.username, selectedURL: $selectedURL) {
                            dismiss()
                        })
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        print("Add Library")
                    } label: {
                        Label(LocalizedStringKey("Add Library"), systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("Cancel"))
                    }
                    
                }
            }
            if (userState.myLibraries?.count ?? -1) == -1 {
                ProgressView()
            }
        }
    }
}


struct LibraryDialog: View {
    @EnvironmentObject var userState: User
    
    var body: some View {
        Button {
//            print("Library")
        } label: {
            NavigationLink(destination: LibraryDialogTable(title: "Manage Libraries", filter: .all, selectedURL: .constant(""))) { Label(LocalizedStringKey("Library"), systemImage: "building.columns") }
        }
    }
}

struct NavigableLibraryDialog: View {
    @EnvironmentObject var userState: User
    @State var filter: Filter = .all
    @State var query: String = ""
    @Binding var selectedURL: String
    var body: some View {
        NavigationView {
            LibraryDialogTable(title: "Select Libary Items", filter: filter, query: query, selectMode: true, selectedURL: $selectedURL)
        }
    }
}

