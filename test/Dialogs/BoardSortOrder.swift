//
//  BoardSortOrder.swift
//  test
//
//  Created by Kenneth Stott on 4/29/23.
//

import SwiftUI

enum SortTypes {
    case notSorted
    case random
    case alphabetic
    case useFrequency
    case backgroundColor
}
struct BoardSortOrder: View {
    
    var save: (() -> Void)? = nil
    var cancel:  (() -> Void)? = nil
    @State var firstSort: SortTypes = .notSorted
    @State var secondSort: SortTypes = .notSorted
    @State var thirdSort: SortTypes = .notSorted

    init(save: @escaping () -> Void, cancel: @escaping () -> Void) {
        self.save = save
        self.cancel = cancel
    }
    var body: some View {
        NavigationView {
            HStack {
                Form {
                    Picker("First Sort", selection: $firstSort) {
                        Text("Not Sorted").tag(SortTypes.notSorted)
                        Text("Random").tag(SortTypes.random)
                        Text("Alphabetic").tag(SortTypes.alphabetic)
                        Text("Use Frequency").tag(SortTypes.useFrequency)
                        Text("Background Color").tag(SortTypes.backgroundColor)
                    }
                    Picker("Second Sort", selection: $secondSort) {
                        Text("Not Sorted").tag(SortTypes.notSorted)
                        Text("Random").tag(SortTypes.random)
                        Text("Alphabetic").tag(SortTypes.alphabetic)
                        Text("Use Frequency").tag(SortTypes.useFrequency)
                        Text("Background Color").tag(SortTypes.backgroundColor)
                    }
                    Picker("Third Sort", selection: $thirdSort) {
                        Text("Not Sorted").tag(SortTypes.notSorted)
                        Text("Random").tag(SortTypes.random)
                        Text("Alphabetic").tag(SortTypes.alphabetic)
                        Text("Use Frequency").tag(SortTypes.useFrequency)
                        Text("Background Color").tag(SortTypes.backgroundColor)
                    }
                }
                .navigationBarTitle("Board Sort Order")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            save!()
                        } label: {
                            Text("Save")
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            cancel!()
                        } label: {
                            Text("Cancel")
                        }
                        
                    }
                }
            }
        }
    }
}

