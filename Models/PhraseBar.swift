//
//  PhraseBar.swift
//  test
//
//  Created by Kenneth Stott on 1/25/23.
//

import Foundation

class PhraseBarState: ObservableObject {
    @Published var contents: [Content] = []
}