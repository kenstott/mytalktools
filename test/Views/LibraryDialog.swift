//
//  LibraryDialog.swift
//  test
//
//  Created by Kenneth Stott on 3/4/23.
//

import SwiftUI

struct LibraryDialogTable: View {
    @EnvironmentObject var userState: User
    
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
                Section(header: Text("My Libraries")) {
                    ForEach((userState.myLibraries ?? []), id: \.self) { row in
                        NavigationLink(row.Name, destination: LibraryView(root: row, username: userState.username))
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
                Section(header: Text("Libraries Shared With Me")) {
                    ForEach((userState.sharedLibraries ?? []), id: \.self) { row in
                        NavigationLink(getLibraryTitle(row), destination: LibraryView(root: row, username: userState.username))
                    }
                }
            }
            .navigationTitle("Manage Libraries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        print("Add Library")
                    } label: {
                        Label(LocalizedStringKey("Add Library"), systemImage: "plus")
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
            print("Library")
        } label: {
            NavigationLink(destination: LibraryDialogTable()) { Label(LocalizedStringKey("Library"), systemImage: "building.columns") }
        }
    }
}

