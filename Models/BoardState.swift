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
    @Published var dbUrl: URL?
    @Published var undoPointer = -1
    var undoable: Bool {
        get {
            return undoPointer != -1
        }
    }
    
    var redoable: Bool {
        get {
            return undoPointer + 1 < undoFiles.count
        }
    }
    
    var undoFiles: [URL] = []
    
    func createUndoSlot() {
        do {
            let undoUrl = dbUrl!.appendingPathExtension("\(undoPointer + 1)")
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: undoUrl.path, isDirectory: &isDirectory) {
                try fileManager.removeItem(atPath: undoUrl.path)
            }
            try fileManager.copyItem(at: dbUrl!, to: undoUrl);
            undoFiles.append(undoUrl)
            undoPointer = undoPointer + 1;
        } catch let error {
            print(error)
        }
    }
    
    func undo() {
        guard undoPointer == -1 else {
            do {
                let undoUrl = dbUrl!.appendingPathExtension("\(undoPointer)")
                let swapUrl = dbUrl!.appendingPathExtension("swap")
                state = .closed
                BoardState.db!.close()
                var isDirectory: ObjCBool = false
                
                // keep track of start state
                if fileManager.fileExists(atPath: swapUrl.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: swapUrl.path)
                }
                try fileManager.copyItem(at: dbUrl!, to: swapUrl);
                
                // overwrite current state with undo state
                if fileManager.fileExists(atPath: dbUrl!.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: dbUrl!.path)
                }
                try fileManager.copyItem(at: undoUrl, to: dbUrl!);
                
                // swap undo state with start state
                if fileManager.fileExists(atPath: undoUrl.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: undoUrl.path)
                }
                try fileManager.copyItem(at: swapUrl, to: undoUrl);
                
                undoPointer = undoPointer - 1;
                reloadDatabase(fileURL: dbUrl!)
            } catch let error {
                print(error)
            }
            return
        }
    }
    
    func redo() {
        guard undoPointer + 1 >= undoFiles.count else {
            do {
                let redoUrl = dbUrl!.appendingPathExtension("\(undoPointer + 1)")
                let swapUrl = dbUrl!.appendingPathExtension("swap")
                state = .closed
                BoardState.db!.close()
                var isDirectory: ObjCBool = false
                
                // keep track of start state
                if fileManager.fileExists(atPath: swapUrl.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: swapUrl.path)
                }
                try fileManager.copyItem(at: dbUrl!, to: swapUrl);
                
                // overwrite current state with undo state
                if fileManager.fileExists(atPath: dbUrl!.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: dbUrl!.path)
                }
                try fileManager.copyItem(at: redoUrl, to: dbUrl!);
                
                // swap undo state with start state
                if fileManager.fileExists(atPath: redoUrl.path, isDirectory: &isDirectory) {
                    try fileManager.removeItem(atPath: redoUrl.path)
                }
                try fileManager.copyItem(at: swapUrl, to: redoUrl);
                
                undoPointer = undoPointer + 1;
                reloadDatabase(fileURL: dbUrl!)
            } catch let error {
                print(error)
            }
            return
        }
    }
    
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
        dbUrl = fileURL;
        BoardState.db = db
        state = .ready
        self.db = db
    }
    
    init() {
        Board.initializeBoard()
    }
}
