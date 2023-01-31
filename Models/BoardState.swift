//
//  DataWrapper.swift
//  test
//
//  Created by Kenneth Stott on 12/31/22.
//

import Foundation
import FMDB
	
class BoardState: ObservableObject {
    
    static var db: FMDatabase?

    enum State {
            case closed
            case ready
        }

    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var getNewDatabase = Network<NewDatabase, NewDatabaseInput>(service: "GetNewDatabase")
    var getNewDatabaseMultiboard = Network<NewDatabase, NewDatabaseInput>(service: "GetNewDatabaseMultiboard")

    @Published private(set) var state = State.closed
    @Published var authorMode = false
    @Published var isPortrait = true
    @Published var editMode = false
    @Published var board: NewDatabase?
    @Published var db: FMDatabase?
    
    func overwriteDevice(dbUser: URL, username: String, media: Media, boardID: String?) async -> Void {
        do {
            let board = try await boardID != nil && boardID != ""
            ? getNewDatabaseMultiboard.execute(params: NewDatabaseInput(userName: username, uuid: "123", boardID: boardID))
            : getNewDatabase.execute(params: NewDatabaseInput(userName: username, uuid: "123"))
            try board?.d.DatabaseImageData.write(to: dbUser)
            media.syncMedia(board?.d.DirectoryList ?? [])
            DispatchQueue.main.async {
                self.board = board
            }
        } catch let error {
            print(error)
        }
    }
    
    func setUserDb(username: String, boardID: String?, media: Media) async {
        DispatchQueue.main.async {
            if self.state == .ready {
                self.state = .closed
            }
        }
        let destURL = username != "" ? documentsURL!.appendingPathComponent(username).appendingPathComponent("Private Library") : documentsURL
        let dbUser = destURL!
            .appendingPathComponent(username == "" ? "sample" : "user" + (boardID ?? "")
                .replacingOccurrences(of: "/", with: "_")
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
            .appendingPathExtension("sqlite")
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: dbUser.path, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(at: destURL!, withIntermediateDirectories: true)
            } catch let error {
                print(error)
            }
        }
        if !fileManager.fileExists(atPath: dbUser.path, isDirectory: &isDirectory) {
            await overwriteDevice(dbUser: dbUser, username: username, media: media, boardID: boardID)
        }
        DispatchQueue.main.async {
            self.reloadDatabase(fileURL: dbUser)
        }
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
        Board.initializeBoard()
    }
}
