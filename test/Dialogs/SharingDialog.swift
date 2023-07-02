//
//  SharingDialog.swift
//  test
//
//  Created by Kenneth Stott on 1/8/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct SharingDialog: View {
    @State private var isConfirming = false
    @State private var dialogDetail: Board
    
    init(board: Board) {
        self.dialogDetail = board
    }
    var body: some View {
        Button {
            isConfirming = true
        } label: {
            Label("Sharing", systemImage: "square.and.arrow.up")
        }
        
        .confirmationDialog(
            "Board \"\(dialogDetail.name)\"",
            isPresented: $isConfirming, presenting: dialogDetail
        ) { detail in
            Button {
                // Handle import action.
            } label: {
                Text(LocalizedStringKey("URL"))
            }
            Button {
                // Handle import action.
            } label: {
                Text(LocalizedStringKey("PDF"))
            }
            Button {
                // Handle import action.
            } label: {
                Text(LocalizedStringKey("Image"))
            }
            Button(LocalizedStringKey("Cancel"), role: .cancel) {
                
            }
            
        } message: { detail in
            Text(
                """
                \(NSLocalizedString("Share", comment: "")) \"\(dialogDetail.name)\" in which format?
                """)
        }
        
    }
}
