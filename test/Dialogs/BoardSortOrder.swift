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
                    Picker(LocalizedStringKey("First Sort"), selection: $firstSort) {
                        Text(LocalizedStringKey("Not Sorted")).tag(SortTypes.notSorted)
                        Text(LocalizedStringKey("Random")).tag(SortTypes.random)
                        Text(LocalizedStringKey("Alphabetic")).tag(SortTypes.alphabetic)
                        Text(LocalizedStringKey("Use Frequency")).tag(SortTypes.useFrequency)
                        Text(LocalizedStringKey("Background Color")).tag(SortTypes.backgroundColor)
                    }
                    Picker(LocalizedStringKey("Second Sort"), selection: $secondSort) {
                        Text(LocalizedStringKey("Not Sorted")).tag(SortTypes.notSorted)
                        Text(LocalizedStringKey("Random")).tag(SortTypes.random)
                        Text(LocalizedStringKey("Alphabetic")).tag(SortTypes.alphabetic)
                        Text(LocalizedStringKey("Use Frequency")).tag(SortTypes.useFrequency)
                        Text(LocalizedStringKey("Background Color")).tag(SortTypes.backgroundColor)
                    }
                    Picker(LocalizedStringKey("Third Sort"), selection: $thirdSort) {
                        Text(LocalizedStringKey("Not Sorted")).tag(SortTypes.notSorted)
                        Text(LocalizedStringKey("Random")).tag(SortTypes.random)
                        Text(LocalizedStringKey("Alphabetic")).tag(SortTypes.alphabetic)
                        Text(LocalizedStringKey("Use Frequency")).tag(SortTypes.useFrequency)
                        Text(LocalizedStringKey("Background Color")).tag(SortTypes.backgroundColor)
                    }
                }
                .navigationBarTitle(LocalizedStringKey("Board Sort Order"))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            save!()
                        } label: {
                            Text(LocalizedStringKey("Save"))
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            cancel!()
                        } label: {
                            Text(LocalizedStringKey("Cancel"))
                        }
                        
                    }
                }
            }
        }
    }
}

