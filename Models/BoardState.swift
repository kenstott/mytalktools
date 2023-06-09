//
//  DataWrapper.swift
//  test
//
//  Created by Kenneth Stott on 12/31/22.
//

import Foundation
import FMDB

enum SyncApproach {
    case overwriteLocal, overwriteRemote, merge
}

enum WriteApproach {
    case uploadToRemote, downloadToLocal, doNothing
}

class ContentStub: Identifiable {
    var id: Int = 0
    var contentType: ContentType = .imageSoundName
    var name: String = ""
    var parentBoard: UInt = 0
    var link: UInt = 0
    var childBoard: UInt = 0 {
        didSet {
            if childBoard != 0 {
                self.children = [ContentStub]()
                self.filteredChildren = self.children
                DispatchQueue.main.async { [self] in
                    setChildren(children: Board().setId(childBoard, "").contents)
                    self.filteredChildren = self.children?.filter {
                        var t1 = max($0.childBoard, $0.link) == 0 && $0.name != "" && $0.contentType != .goBack && $0.contentType != .goHome
                        var t2 = max($0.childBoard, $0.link) != 0
                        return t1 || t2
                    }
                }
            }
        }
    }
    var query = "" {
        didSet {
            // filter to leaf cells that match
            if query != "" {
                filteredChildren = children?.filter {
                    (max($0.childBoard, $0.link) == 0 && $0.name.lowercased().contains(query.lowercased()) && $0.contentType != .goBack && $0.contentType != .goHome) || ($0.filteredChildren?.count ?? 0) != 0
                }
            } else {
                filteredChildren = children?.filter {
                    (max($0.childBoard, $0.link) == 0 && $0.name != "" && $0.contentType != .goBack && $0.contentType != .goHome) || ($0.filteredChildren?.count ?? 0) != 0
                }
            }
            filteredChildren = filteredChildren?.map {
                $0.query = query
                $0.isExpanded = query != ""
                return $0
            }
            filteredChildren = filteredChildren?.filter {
                (max($0.childBoard, $0.link) == 0 && $0.name != "" && $0.contentType != .goBack && $0.contentType != .goHome) || ($0.filteredChildren?.count ?? 0) != 0
            }
        }
    }
    var children: [ContentStub]? = nil
    var filteredChildren: [ContentStub]? = nil
    var isExpanded = false
    
    func setFromContent(content: Content) -> ContentStub {
        let c = ContentStub()
        c.id = content.id
        c.contentType = content.contentType
        c.parentBoard = UInt(content.boardId)
        c.name = content.name
        c.link = content.childBoardLink
        c.childBoard = content.childBoardId
        return c
    }
    
    func setChildren(children: [Content]) {
        self.children = children.map {
            ContentStub().setFromContent(content: $0)
        }
        self.filteredChildren = self.children
    }
}

class BoardState: ObservableObject {
    
    static var db: FMDatabase?
    static var dbUrl: URL?
    
    enum State {
        case closed
        case ready
    }
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var getNewDatabase = Network<NewDatabase, NewDatabaseInput>(service: "GetNewDatabase")
    var getNewDatabaseMultiboard = Network<NewDatabase, NewDatabaseInput>(service: "GetNewDatabaseMultiboard")
    var syncMergePost = Network<SyncMergeResultParent, SyncMergeInput>(service: "MergeDataMultiBoardAndroid")
    
    @Published private(set) var state = State.closed
    @Published var authorMode = false
    @Published var isPortrait = true
    @Published var editMode = false
    @Published var board: NewDatabase?
    @Published var db: FMDatabase?
    @Published var dbUrl: URL?
    @Published var undoPointer = -1
    @Published var copyBuffer = EditableContent()
    @Published var boardTree = [ContentStub]()
    @Published var boardTreeFiltered = [ContentStub]()
    @Published var directNavigateBoard: UInt = 0
    @Published var viewedBoard: BoardView? = nil

    @Published var boardTreeSearch = "" {
        didSet {
            if boardTreeSearch != "" {
                boardTreeFiltered = boardTree.filter {
                    $0.name.lowercased().contains(boardTreeSearch.lowercased()) || max($0.childBoard, $0.link) != 0
                }
            } else {
                boardTreeFiltered = boardTree
            }
            boardTreeFiltered = boardTreeFiltered.map {
                $0.query = boardTreeSearch
                $0.isExpanded = boardTreeSearch != ""
                return $0
            }
            boardTreeFiltered = boardTreeFiltered.filter {
                max($0.childBoard, $0.link) == 0 || $0.filteredChildren?.count != 0
            }
        }
    }
    
    func updateBoardTree(_ username: String, contentStub: ContentStub) {
        let link = max(contentStub.childBoard, contentStub.link)
        if link == 0 && boardTree.count == 0 {
            DispatchQueue.main.async { [self] in
                boardTree = Board()
                    .setId(1, username)
                    .contents.map {
                        ContentStub().setFromContent(content: $0)
                    }
                boardTreeFiltered = boardTree
                print(boardTree.count)
            }
        } else if link > 1 && contentStub.children == nil {
            DispatchQueue.main.async {
                contentStub.setChildren(children: Board().setId(link, username).contents)
            }
        }
    }
    
    func updateUsage(_ content: Content, _ username: String, _ boardName: String ) {
        let url = documentsURL!.appendingPathComponent(username).appendingPathComponent("\(username)\(boardName != "" ? "-" + boardName : "")-usage.json")
        let key = content.id == -1 ? content.name : String(content.id)
        var usage = [String:Int]()
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let contents = try String(contentsOfFile: url.path)
                usage = try JSONDecoder().decode([String:Int].self, from: contents.data(using: .utf8)!)
            } catch {
                usage = [String:Int]()
            }
        }
        if usage[key] == nil {
            usage[key] = 1
        } else {
            usage[key] = usage[key]! + 1
        }
        do {
            let output = try JSONEncoder().encode(usage)
            print(String(data: output, encoding: .utf8)!)
            try output.write(to: url)
        } catch let error {
            print(error.localizedDescription)
        }
        print(url)
    }
    
    func updateMru(_ content: Content, _ username: String, _ boardName: String ) {
        let key = "mru.\(username)\(boardName != "" ? "." + boardName : "")"
        do {
            var result: [LibraryContent] = try JSONDecoder().decode([LibraryContent].self, from: Data((UserDefaults.standard.string(forKey: key) ?? "[]").utf8))
            let index = result.firstIndex(of: LibraryContent.convert(content))
            if index != nil {
                result.remove(at: index!)
            }
            result.insert(LibraryContent.convert(content), at: 0)
            let mru = String(data: try! JSONEncoder().encode(result), encoding: .utf8) ?? "[]"
            UserDefaults.standard.set(mru, forKey: key)
        } catch {
            UserDefaults.standard.set("[]", forKey: key)
        }
    }
    
    func getMru(_ username: String, _ boardName: String ) -> [Content] {
        let key = "mru.\(username)\(boardName != "" ? "." + boardName : "")"
        do {
            let result: [LibraryContent] = try JSONDecoder().decode([LibraryContent].self, from: Data((UserDefaults.standard.string(forKey: key) ?? "[]").utf8))
            return result.map { Content().copyLibraryContent($0) }
        } catch {
            return []
        }
    }
    
    func getMostUsed(_ username: String, _ boardName: String ) -> [Content] {
        let url = documentsURL!.appendingPathComponent(username).appendingPathComponent("\(username)\(boardName != "" ? "-" + boardName : "")-usage.json")
        var usage = [String:Int]()
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let contents = try String(contentsOfFile: url.path)
                usage = try JSONDecoder().decode([String:Int].self, from: contents.data(using: .utf8)!)
            } catch {
                usage = [String:Int]()
            }
        }
        let sortedDict = usage.sorted { $0.0 < $1.0 }
        let contents: [Content] = sortedDict.map {
            let content = Content()
            let id = Int($0.key)
            if id == nil {
                content.name = $0.key
            } else {
                _ = content.setId(id!)
            }
            return content
        }
        return contents
    }
    
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
    
    func getDatabaseImage() -> String? {
        do {
            let fileData = try Data.init(contentsOf: dbUrl!)
            return fileData.base64EncodedString()
        } catch {
            print("error")
            print(error.localizedDescription)
        }
        return nil
    }
    
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
            print(error.localizedDescription)
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
                print(error.localizedDescription)
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
                print(error.localizedDescription)
            }
            return
        }
    }
    
    func merge(username: String, boardID: String, media: Media) async {
        do {
            await media.WriteMediaFilesToServer(username: username)
            let dbImage = getDatabaseImage() ?? ""
            let board = try await syncMergePost.execute(params: SyncMergeInput(databaseImage: dbImage, userName: username, uuid: "123", boardID: boardID))
            try board?.d.DatabaseImageData.write(to: dbUrl!)
            await media.syncMedia(board?.d.DirectoryList ?? [], syncApproach: .merge)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func overwriteDevice(dbUser: URL, username: String, media: Media, boardID: String?) async -> Void {
        do {
            let board = try await boardID != nil && boardID != ""
            ? getNewDatabaseMultiboard.execute(params: NewDatabaseInput(userName: username, uuid: "123", boardID: boardID))
            : getNewDatabase.execute(params: NewDatabaseInput(userName: username, uuid: "123"))
            try board?.d.DatabaseImageData.write(to: dbUser)
            await media.syncMedia(board?.d.DirectoryList ?? [], syncApproach: .overwriteLocal)
            DispatchQueue.main.async {
                self.board = board
            }
        } catch let error {
            print(error.localizedDescription)
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
                print(error.localizedDescription)
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
        BoardState.dbUrl = fileURL
        BoardState.db = db
        state = .ready
        self.db = db
    }
    
    init() {
        Board.initializeBoard()
    }
}
