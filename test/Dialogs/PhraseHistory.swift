//
//  LibraryDialog.swift
//  test
//
//  Created by Kenneth Stott on 3/4/23.
//

import SwiftUI

struct PhraseHistory: View {
    
    @EnvironmentObject var userState: User
    @EnvironmentObject var phraseBarState: PhraseBarState
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("BoardName") var storedBoardName = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let favoritesList = phraseBarState.getPhraseFavorites(storedUsername, storedBoardName)
        let favorites = phraseBarState.getPhraseHistory(storedUsername, storedBoardName).filter { favoritesList.contains(phraseBarState.getPhraseHash(phrase: $0)) }
        return ZStack {
            List {
                Section {
                    ForEach(favorites, id: \.self) { row in
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {ForEach(Array(row.enumerated()), id: \.offset) { offset, item in
                                ZStack(alignment: .center) {
                                    ContentView(
                                        .constant(item),
                                        selectMode: false,
                                        onClick: { (taps: Int) -> Void in
                                            phraseBarState.replaceContents(row)
                                            dismiss()
                                        },
                                        maximumCellHeight: .constant(65),
                                        cellWidth: .constant(65),
                                        board: .constant(Board()),
                                        refresh: 0,
                                        zoomHeight: 250.0,
                                        zoomWidth: 250.0,
                                        fromPhraseBar: true
                                    )
                                    .id(offset + 1)
                                }
                            }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                phraseBarState.updatePhraseFavorite(username: storedUsername, phrase: row, value: false)
                                dismiss()
                            } label: {
                                Label("Remove from favorites", systemImage: "star.slash").foregroundColor(Color.black)
                            }
                            .background(Color.blue)
                        }
                        .onTapGesture {
                            phraseBarState.replaceContents(row)
                            dismiss()
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("Favorites"))
                }
                Section {
                    ForEach((phraseBarState.getPhraseHistory(storedUsername, storedBoardName)), id: \.self) { row in
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {ForEach(Array(row.enumerated()), id: \.offset) { offset, item in
                                ZStack(alignment: .center) {
                                    ContentView(
                                        .constant(item),
                                        selectMode: false,
                                        onClick: { (taps: Int) -> Void in
                                            phraseBarState.replaceContents(row)
                                            dismiss()
                                        },
                                        maximumCellHeight: .constant(65),
                                        cellWidth: .constant(65),
                                        board: .constant(Board()),
                                        refresh: 0,
                                        zoomHeight: 250.0,
                                        zoomWidth: 250.0,
                                        fromPhraseBar: true
                                    )
                                    .id(offset + 1)
                                }
                            }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if phraseBarState.getPhraseFavorites(storedUsername, storedBoardName).contains(phraseBarState.getPhraseHash(phrase: row)) {
                                Button(role: .destructive) {
                                    phraseBarState.updatePhraseFavorite(username: storedUsername, phrase: row, value: false)
                                    dismiss()
                                } label: {
                                    Label("Remove from favorites", systemImage: "star.slash")
                                }
                            } else {
                                Button(role: .none) {
                                    phraseBarState.updatePhraseFavorite(username: storedUsername, phrase: row, value: true)
                                    dismiss()
                                } label: {
                                    Label("Add to favorites", systemImage: "star.fill")
                                }
                            }
                        }
                        .onTapGesture {
                            phraseBarState.replaceContents(row)
                            dismiss()
                        }
                    }
                } header: {
                    Text(LocalizedStringKey("History"))
                }
            }
            .navigationTitle(LocalizedStringKey("Phrase History"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("Cancel"))
                    }
                }
            }
        }
    }
}

