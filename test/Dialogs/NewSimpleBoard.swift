//
//  BoardSortOrder.swift
//  test
//
//  Created by Kenneth Stott on 4/29/23.
//

import SwiftUI

struct NewSimpleBoard: View {
    
    @Binding var rows: Int
    @Binding var columns: Int
    @State var done: (_ cancel: Bool) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            HStack {
                Form {
                    Picker("Rows", selection: $rows) {
                        ForEach(1 ..< 16) { i in
                            Text(String(i)).tag(i)
                        }
                    }
                    Picker("Columns", selection: $columns) {
                        ForEach(1 ..< 16) { i in
                            Text(String(i)).tag(i)
                        }
                    }
                }
                .navigationBarTitle("New Board")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            dismiss()
                            done(false)
                        } label: {
                            Text(LocalizedStringKey("Save"))
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            dismiss()
                            done(true)
                        } label: {
                            Text(LocalizedStringKey("Cancel"))
                        }
                        
                    }
                }
            }
        }
    }
}

