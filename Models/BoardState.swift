//
//  DataWrapper.swift
//  test
//
//  Created by Kenneth Stott on 12/31/22.
//

import Foundation
import FMDB
	
class BoardState: ObservableObject {
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    enum State {
            case closed
            case ready
        }

    @Published private(set) var state = State.closed
    @Published var authorMode = false
    @Published var isPortrait = true
    @Published var editMode = false
    @Published var db: FMDatabase?
    
    static var db: FMDatabase?
    var getNewDatabase = Network<NewDatabase, NewDatabaseInput>(service: "GetNewDatabase")
    
    func setUserDb(username: String, media: Media) async {
        DispatchQueue.main.async {
            if (self.state == .ready) {
                self.state = .closed
            }
        }
        let destURL = username != "" ? documentsURL!.appendingPathComponent(username).appendingPathComponent("Private Library") : documentsURL
        let dbUser = destURL!.appendingPathComponent(username == "" ? "sample" : "user").appendingPathExtension("sqlite")
        var isDirectory: ObjCBool = false
        var board: NewDatabase?
        if !fileManager.fileExists(atPath: dbUser.path, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(at: destURL!, withIntermediateDirectories: true)
                board = try await getNewDatabase.execute(params: NewDatabaseInput(userName: username, uuid: "123"))
                try board?.d.DatabaseImageData.write(to: dbUser)
            } catch let error {
                print(error)
            }
        }
        DispatchQueue.main.async {
            self.reloadDatabase(fileURL: dbUser)
        }
        media.syncMedia(board?.d.DirectoryList ?? [])
    }

    func reloadDatabase(fileURL: URL) {
        
        if (BoardState.db != nil) {
            state = .closed
            BoardState.db!.close()
        }
        
        let db = FMDatabase(url: fileURL)
        guard db.open() else {
            fatalError("Unable to open database")
        }
        BoardState.db = db
        state = .ready
        self.db = db
    }
    
    init() {
        initializeBoard()
    }
}
