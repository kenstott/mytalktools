//
//  DataWrapper.swift
//  test
//
//  Created by Kenneth Stott on 12/31/22.
//

import Foundation
import FMDB

class DataWrapper: ObservableObject {
    
    @Published var authorMode = false
    @Published var isPortrait = true
    static var db: FMDatabase?
    
    init(fileName: String = "sample") {
        // 1 - Get filePath of the SQLite file
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(fileName).sqlite")
        
        // 2 - Create FMDatabase from filePath
        let db = FMDatabase(url: fileURL)
        
        // 3 - Open connection to database
        guard db.open() else {
            fatalError("Unable to open database")
        }
                
        DataWrapper.db = db
    }
}
