import Foundation
import SwiftUI
import FMDB

struct LibraryBoardIdInput: Convertable {
    var boardId: UInt
}

class Board: Hashable, Identifiable, ObservableObject, Equatable {
    
    var getBoardPost = GetPost<LibraryBoard, LibraryBoardIdInput>(service: "GetBoard")
    
    func setColumn(column: String, value: Any) -> Void {
        BoardState.db!.executeUpdate("UPDATE board set \(column) = ? WHERE iphone_board_id = ?", withArgumentsIn: [value,id]);
    }

    func save() -> Void {
        setColumn(column: "board_name", value: name)
        setColumn(column: "board_clms", value: columns)
        setColumn(column: "board_rows", value: rows)
        setColumn(column: "sort1", value: sort[0])
        setColumn(column: "sort2", value: sort[1])
        setColumn(column: "sort3", value: sort[2])
        setColumn(column: "update_date", value: ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: "T", with: " "))
    }

    static func initializeBoard() {
        let nameForFile = "sample"
        let extForFile = "sqlite"
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
        if fileManager.fileExists(atPath: destURL.path) {
            return;
        } else {
            guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
                else {
                    print("Source File not found.")
                    return
            }
            do {
                let originalContents = try Data(contentsOf: sourceURL)
                try originalContents.write(to: destURL, options: .atomic)
            } catch {
                print("Unable to write file")
            }
        }
    }
    
    func getString(id: UInt, column: String, defaultValue: String = "") -> String {
        var result: String = defaultValue
        let s = BoardState.db?.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.string(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }

    func getInt(id: UInt, column: String, defaultValue: Int = -1) -> Int {
        var result: Int = defaultValue
        let s = BoardState.db?.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            result = s?.long(forColumnIndex: 0) ?? defaultValue
        }
        s?.close()
        return result
    }

    private func getContents(id: UInt) -> [Content] {
        var result: [Content] = []
        let s = BoardState.db?.executeQuery("SELECT iphone_content_id FROM content WHERE board_id = ?", withArgumentsIn: [id]) ?? FMResultSet();
        while s.next() {
            result.append(Content().setId(s.long(forColumnIndex: 0)))
        }
        s.close()
        return result;
    }

    private func getSort(id: UInt) -> [Int] {
        var sort: [Int] = [0,0,0]
        let s = BoardState.db?.executeQuery("SELECT sort1, sort2, sort3 FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
        if s?.next() != nil {
            sort[0] = s?.long(forColumnIndex: 0) ?? 0
            sort[1] = s?.long(forColumnIndex: 1) ?? 0
            sort[2] = s?.long(forColumnIndex: 2) ?? 0
        }
        s?.close()
        return sort
    }

    static func == (lhs: Board, rhs: Board) -> Bool {
        guard lhs.contents == rhs.contents else {
            return false
        }
        guard lhs.columns == rhs.columns else {
            return false
        }
        guard lhs.rows == rhs.rows else {
            return false
        }
        guard lhs.name == rhs.name else {
            return false
        }
        guard lhs.sort == rhs.sort else {
            return false
        }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(contents)
        hasher.combine(columns)
        hasher.combine(rows)
        hasher.combine(name)
        hasher.combine(sort)
        hasher.combine(id)
    }
    
    @Published var contents: [Content] = [] {
        didSet {
            filteredContents = self.contents.filter { $0.externalUrl != "x" }
        }
    }
    @Published var filteredContents: [Content] = []
    @Published var columns: Int = 0
    @Published var rows: Int = 0
    @Published var userId: Int = -1
    @Published var name: String = ""
    @Published var sort: [Int] = [0,0,0]
    @Published var id: UInt = 0
    
    init() {
        columns = 0
    }
    
    func setId(_ id: UInt) -> Board {
        self.id = id;
        self.contents = getContents(id: id)
        if self.contents.count > 0 {
            self.columns = getInt(id: id, column: "board_clms", defaultValue: -1)
            self.rows = getInt(id: id, column: "board_rows", defaultValue: -1)
            self.name = getString(id: id, column: "board_name", defaultValue: "Unknown")
            self.userId = getInt(id: id, column: "user_id", defaultValue: -1)
            self.sort = getSort(id: id)
            calcCellSizes()
            sortContent()
//            self.filteredContents = self.contents.filter { $0.externalUrl != "x" }
        } else {
            Task {
                do {
                    let remoteBoard = try await getBoardPost.execute(params: LibraryBoardIdInput(boardId: id))
                    DispatchQueue.main.async {
                        self.columns = remoteBoard?.WebBoard.Columns ?? 0
                        self.rows = remoteBoard?.WebBoard.Rows ?? 0
                        self.userId = -1
                        self.sort[0] = remoteBoard?.WebBoard.Sort1 ?? 0
                        self.sort[1] = remoteBoard?.WebBoard.Sort2 ?? 0
                        self.sort[2] = remoteBoard?.WebBoard.Sort3 ?? 0
                        var currentRow = 1
                        var currentColumn = 1
                        self.contents = remoteBoard?.Contents.map {
                            let row = $0
                            var libraryContent = LibraryContent()
                            libraryContent.ContentId = row.WebContentId
                            libraryContent.Text = row.contentName
                            libraryContent.Picture = "\(UserUploadUrl)\(row.contentUrl.replacingOccurrences(of: "%2F", with: "/").replacingOccurrences(of: "%2E", with: "."))"
                            libraryContent.Sound = "\(UserUploadUrl)\(row.contentUrl2.replacingOccurrences(of: "%2F", with: "/").replacingOccurrences(of: "%2E", with: "."))"
                            let content = Content().copyLibraryContent(libraryContent)
                            content.boardId = Int(id)
                            content.contentType = ContentType(rawValue: row.contentType) ?? .imageSoundName
                            content.row = currentRow
                            content.column = currentColumn
                            currentColumn += 1
                            if currentColumn > self.columns {
                                currentRow += 1
                                currentColumn = 1
                            }
                            return content
                        } ?? []
                        self.calcCellSizes()
                        self.sortContent()
//                        self.filteredContents = self.contents.filter { $0.externalUrl != "x" }
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        return self
    }
    
    func content(_ id: Int) -> Content? {
        if let i = contents.firstIndex(where: { $0.id == id }) {
            return contents[i]
        }
        return nil
    }
    
    func defaultSortContent() -> [Content] {
        contents.sorted(by: { ( $0.row * columns  + $0.column ) < ( $1.row * columns + $1.column )  })
    }
    
    func sortContent() {
        contents = contents.sorted(by: { ( $0.row * columns  + $0.column ) < ( $1.row * columns + $1.column )  })
    }
    
    func calcCellSizes() {
        let contents = defaultSortContent()
        var anchorCell = Content()
        for content in contents {
            if (content.externalUrl == "x") {
                anchorCell.cellSize += 1
            } else {
                anchorCell = content
                content.cellSize = 1
            }
        }
    }
    
    func swap(id1: Int, id2: Int, boardState: BoardState) -> Bool {
        let content1 = contents.firstIndex(where: {$0.id == id1})
        let content2 = contents.firstIndex(where: {$0.id == id2})
        let c1 = Content().setId(id1)
        let c2 = Content().setId(id2)
        if content1 != nil && content2 != nil {
            let row = c1.row
            let column = c1.column
            c1.row = c2.row
            c1.column = c2.column
            c2.row = row
            c2.column = column
            contents[content1!] = c1
            contents[content2!] = c2
            boardState.createUndoSlot()
            c1.save()
            c2.save()
            save()
            sortContent()
//            filteredContents = contents.filter { $0.externalUrl != "x" }
            return true
        }
        return false
    }
}

