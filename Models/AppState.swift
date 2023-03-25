//
//  AppState.swift
//  test
//
//  Created by Kenneth Stott on 1/15/23.
//

import Foundation

final class AppState : ObservableObject {
    @Published var rootViewId = UUID()
}
