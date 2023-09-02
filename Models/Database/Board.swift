import Foundation
import SwiftUI
import FMDB

struct LibraryBoardIdInput: Convertable {
    var boardId: UInt
}

enum SpecialBoardType: UInt {
    case MostRecent = 99999999999
    case MostUsed =   99999999998
}
/*
 {\"UserID\":12,\"Username\":\"Public\",\"FirstName\":\"special\",\"LastName\":\"user\",\"IsSuperUser\":false,\"AffiliateId\":null,\"Email\":\"ken@kenstott.com\",\"DisplayName\":\"Basic Starter\",\"UpdatePassword\":false,\"LastIPAddress\":\"172.124.73.177\",\"IsDeleted\":false,\"CreatedByUserID\":-1,\"CreatedOnDate\":\"\\/Date(1268451774240)\\/\",\"LastModifiedByUserID\":-1,\"LastModifiedOnDate\":\"\\/Date(1690636526813)\\/\",\"PasswordResetToken\":\"2919951b-c031-43d5-9460-83b21b7bb4f4\",\"PasswordResetExpiration\":\"\\/Date(1491946724943)\\/\",\"LowerEmail\":\"ken@kenstott.com\",\"PortalId\":0,\"Authorised\":true,\"IsDeleted1\":false,\"RefreshRoles\":false,\"VanityUrl\":\"\"}
 */

struct SampleBoard: Decodable, Encodable, Hashable {
    var UserID: Int = 0
    var Username: String = ""
    var FirstName: String? = ""
    var LastName: String? = ""
    var IsSuperUser: Bool? = false
    var Email: String? = ""
    var DisplayName: String? = ""
    var UpdatePassword: Bool? = false
    var LastIPAddress: String? = ""
    var IsDeleted: Bool? = false
    var CreatedByUserID: Int? = 0
    var CreatedOnDate: String? = ""
    var LastModifiedByUserID: Int? = 0
    var LastModifiedOnDate: String? = ""
    var PasswordResetToken: String? = ""
    var PasswordResetExpiration: String? = ""
    var LowerEmail: String? = ""
    var PortalId: Int? = 0
    var Authorised: Bool? = false
    var IsDeleted1: Bool? = false
    var RefreshRoles: Bool? = false
    var VanityUrl: String? = ""
}

struct SampleBoardResult: Decodable, Encodable {
    var d: String
    var dd: [SampleBoard] {
        get {
            return getSampleBoardResults(json: self.d)
        }
    }
}

struct OverwriteFromSampleInput: Decodable, Encodable {
    var userName: String
    var uuid: String
    var copyFromUserName: String
}

func getSampleBoardResults(json: String) -> Array<SampleBoard> {
    let jsonData = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    do {
        let result = try decoder.decode(Array<SampleBoard>.self, from: jsonData)
        return result
    } catch {
        return []
    }
}

class Board: Hashable, Identifiable, ObservableObject, Equatable {
    
    static private var _getSampleBoards = Network<SampleBoardResult, QueryInput>(service: "Query")
    static private var repeatCells: [Content] = []
    var getBoardPost = GetPost<LibraryBoard, LibraryBoardIdInput>(service: "GetBoard")
    
    static func getSampleBoards() async throws -> [SampleBoard]? {
        guard let result = try await Board._getSampleBoards.execute(
            params: QueryInput(
                query: "EXEC [dbo].[GetUsersByRolename] @PortalID = 0, @Rolename = 'Sample'",
                site: "SiteSqlServer"))?.dd else {
            throw "Problem getting sample boards"
        }
        return result
    }

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
    
    func getRow(_ row: Int) -> [Content] {
        return contents.filter { $0.row == row }
    }
    
    func getColumn(_ column: Int) -> [Content] {
        return contents.filter { $0.column == column }
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
        var total = 0
        var currentRow = 0
        var currentColumn = 0
        let s = BoardState.db?.executeQuery("SELECT iphone_content_id FROM content WHERE board_id = ? ORDER BY row_index ASC, clm_index ASC", withArgumentsIn: [id]) ?? FMResultSet();
        while s.next() {
            let content = Content().setId(s.long(forColumnIndex: 0))
            result.append(content)
            if (content.row > currentRow) {
                currentRow = content.row
            }
            currentColumn = content.column
            total += 1
        }
        s.close()
        
        var contentId = -1
        let ss = BoardState.db?.executeQuery("select max(iphone_content_id) from content", withArgumentsIn: []) ?? FMResultSet();
        while ss.next() {
            contentId = ss.long(forColumnIndex: 0)
        }
        ss.close()
        let boardId = self.id
        while rows * columns > total {
            contentId += 1
            if currentColumn + 1 > self.columns {
                currentRow += 1
                currentColumn = 0
            }
            let content = Content()
            content.row = currentRow
            content.column = currentColumn
            content.id = contentId
            content.userId = 0
            content.boardId = Int(boardId)
            content.insert()
            result.append(content)
            total += 1
            currentColumn += 1
        }
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
    
    func setUseRepeats(_ flag: Bool) {
        self.useRepeats = flag;
    }
    
    private func updateFilteredContents() {
        filteredContents = self.contents.map { $0.copy(id: $0.id) }
        filteredColumns = self.columns
        if id == 1 {
            Board.repeatCells = self.contents.filter { $0.isRepeat }
        } else if useRepeats {
            let topRow = Board.repeatCells.filter { $0.isRepeatRowTop } .map { $0.copy(id: $0.id) }
            let bottomRow = Board.repeatCells.filter { $0.isRepeatRowBottom } .map { $0.copy(id: $0.id) }
            let rightColumn = Board.repeatCells.filter { $0.isRepeatColumnRight } .map { $0.copy(id: $0.id) }
            let leftColumn = Board.repeatCells.filter { $0.isRepeatColumnLeft } .map { $0.copy(id: $0.id) }
            let overlayCells = Board.repeatCells.filter { $0.isRepeatedCellOverlay } .map { $0.copy(id: $0.id) }
            filteredContents = filteredContents.map {
                for cell in overlayCells {
                    if cell.row == $0.row && cell.column == $0.column {
                        return cell
                    }
                }
                return $0
            }
            var rows = self.rows
            if topRow.count > 0 {
                rows += 1
                filteredContents = filteredContents.map {
                    $0.row += 1
                    return $0
                }
                for i in 0..<filteredColumns {
                    let c = Content()
                    c.row = 0
                    c.column = i
                    filteredContents.insert(c, at: i)
                }
            }
            if leftColumn.count > 0 {
                filteredColumns += 1
                filteredContents = filteredContents.map {
                    $0.column += 1
                    return $0
                }
                for i in 0..<rows {
                    let c = Content()
                    c.row = i
                    c.column = 0
                    filteredContents.insert(c, at: i * filteredColumns)
                }
            }
            if bottomRow.count > 0 {
                rows += 1
                for i in 0..<filteredColumns {
                    let c = Content()
                    c.row = rows - 1
                    c.column = i
                    filteredContents.append(c)
                }
            }
            if rightColumn.count > 0 {
                filteredColumns += 1
                for i in 0..<rows {
                    let c = Content()
                    c.row = i
                    c.column = filteredColumns - 1
                    filteredContents.insert(c, at: (i * filteredColumns) + filteredColumns - 1 )
                }
            }
            filteredContents = filteredContents.map {
                for cell in topRow {
                    if $0.row == 0 && cell.column == $0.column {
                        return cell
                    }
                }
                return $0
            }
            filteredContents = filteredContents.map {
                for cell in bottomRow {
                    if $0.row == rows - 1 && cell.column == $0.column {
                        return cell
                    }
                }
                return $0
            }
            filteredContents = filteredContents.map {
                for cell in leftColumn {
                    if cell.row == $0.row && $0.column == 0 {
                        return cell
                    }
                }
                return $0
            }
            filteredContents = filteredContents.map {
                for cell in rightColumn {
                    if cell.row == $0.row && $0.column == filteredColumns - 1 {
                        return cell
                    }
                }
                return $0
            }
        }
        filteredContents = filteredContents.filter { $0.externalUrl != "x" }
    }
    
    @Published var contents: [Content] = [] {
        didSet {
            updateFilteredContents()
        }
    }
    @Published var filteredContents: [Content] = []
    @Published var filteredColumns: Int = 0
    @Published var columns: Int = 0
    @Published var rows: Int = 0
    @Published var userId: Int = -1
    @Published var name: String = ""
    @Published var sort: [Int] = [0,0,0]
    @Published var id: UInt = 0
    @Published var useRepeats = false {
        didSet {
            updateFilteredContents()
        }
    }
    
    init() {
        columns = 0
    }
    
    func setId(_ id: UInt, _ username: String?) -> Board {
        return setId(id, username, nil, nil)
    }
    
    func setId(_ id: UInt, _ username: String?, _ boardName: String?, _ boardState: BoardState?, _ useRepeats: Bool = false) -> Board {
        self.useRepeats = useRepeats
        if id == SpecialBoardType.MostRecent.rawValue && boardState != nil {
            self.id = SpecialBoardType.MostRecent.rawValue
            self.rows = 10
            self.columns = 3
            self.name = NSLocalizedString("Recents", comment: "")
            var row = 1, column = 1
            self.contents = boardState!.getMru(username ?? "", boardName ?? "").map {
                $0.row = row
                $0.column = column
                if column > 3 {
                    column = 1
                    row += 1
                } else {
                    column += 1
                }
                return $0
            }
            return self;
        }
        if id == SpecialBoardType.MostUsed.rawValue && boardState != nil {
            self.id = SpecialBoardType.MostUsed.rawValue
            self.rows = 10
            self.columns = 3
            self.name = NSLocalizedString("Most Used", comment: "")
            var row = 1, column = 1
            self.contents = boardState!.getMostUsed(username ?? "", boardName ?? "").map {
                $0.row = row
                $0.column = column
                if column > 3 {
                    column = 1
                    row += 1
                } else {
                    column += 1
                }
                return $0
            }
            self.columns = min(self.columns, self.contents.count)
            return self;
        }
        self.id = id;
        self.columns = getInt(id: id, column: "board_clms", defaultValue: -1)
        if self.columns > 0 {
            self.rows = getInt(id: id, column: "board_rows", defaultValue: -1)
            self.contents = getContents(id: id)
            self.name = getString(id: id, column: "board_name", defaultValue: "Unknown")
            self.userId = getInt(id: id, column: "user_id", defaultValue: -1)
            self.sort = getSort(id: id)
            calcCellSizes()
            sortContent()
            if username != nil && username != "" {
                for content in self.contents {
                    content.addToSpotlightSearch(username: username!)
                }
            }
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
                            if username != nil {
                                content.addToSpotlightSearch(username: username!)
                            }
                            return content
                        } ?? []
                        
                        self.calcCellSizes()
                        self.sortContent()
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
            return true
        }
        return false
    }
    
    func addRow(boardState: BoardState) {
        boardState.createUndoSlot()
        rows += 1
        save()
        contents = getContents(id: id)
    }
    
    static func getGeoMonitorBoards() -> [Content] {
        var results = [Content]()
        let ss = BoardState.db?.executeQuery("select * from content", withArgumentsIn: []) ?? FMResultSet();
        while ss.next() {
            results.append(Content().setId(ss.long(forColumn: "iphone_content_id")))
        }
        return results.filter { $0.link != 0 && $0.externalUrl.starts(with: "mtgeo") }
    }
    
    static func getScheduleBoards() -> [Content] {
        var results = [Content]()
        let ss = BoardState.db?.executeQuery("select * from content where external_url LIKE 'mtschedule%'", withArgumentsIn: []) ?? FMResultSet();
        while ss.next() {
            results.append(Content().setId(ss.long(forColumn: "iphone_content_id")))
        }
        return results.filter {
            $0.link != 0 && $0.externalUrl.starts(with: "mtschedule")
        }
    }
    
    func addColumn(boardState: BoardState) {
        boardState.createUndoSlot()
        columns += 1
        save()
        var contentId = -1
        let ss = BoardState.db?.executeQuery("select max(iphone_content_id) from content", withArgumentsIn: []) ?? FMResultSet();
        while ss.next() {
            contentId = ss.long(forColumnIndex: 0)
        }
        ss.close()
        let boardId = self.id
        var newContents: [Content] = []
        for rowIndex in 0..<rows {
            for columnIndex in 0..<columns {
                if columnIndex < columns - 1  {
                    let oldIndex = (rowIndex * (columns - 1)) + columnIndex
                    let newContent = contents[oldIndex]
                    newContent.row = rowIndex
                    newContent.column = columnIndex
                    newContent.save()
                    newContents.append(newContent)
                } else {
                    contentId += 1
                    let newContent = Content()
                    newContent.row = rowIndex
                    newContent.column = columnIndex
                    newContent.id = contentId
                    newContent.userId = 0
                    newContent.boardId = Int(boardId)
                    newContent.insert()
                    newContents.append(newContent)
                }
            }
        }
        contents = getContents(id: id)
    }
    
    func deleteLastRow(boardState: BoardState) {
        boardState.createUndoSlot()
        rows -= 1
        save()
        contents = getContents(id: id)
    }
    
    func compressColumns(boardState: BoardState) {
        boardState.createUndoSlot()
        columns -= 1
        rows += 1
        save()
        var index = 0
        for r in 0..<rows {
            for c in 0..<columns {
                if contents.count <= index {
                    contents[index].row = r
                    contents[index].column = c
                    contents[index].save()
                }
                index += 1
            }
        }
        contents = getContents(id: id)
    }
    
    func stretchColumns(boardState: BoardState) {
        boardState.createUndoSlot()
        columns += 1
        save()
        var index = 0
        for r in 0..<rows {
            for c in 0..<columns {
                if contents.count <= index {
                    contents[index].row = r
                    contents[index].column = c
                    contents[index].save()
                }
                index += 1
            }
        }
        contents = getContents(id: id)
    }
    
    func deleteRightColumn(boardState: BoardState) {
        boardState.createUndoSlot()
        var index = 0
        let deletedContents = contents.filter { ($0.column + 1) % columns == 0}
        let newContents = contents.filter { ($0.column + 1) % columns != 0}
        columns -= 1
        for r in 0..<rows {
            for c in 0..<columns {
                if newContents.count <= index {
                    newContents[index].row = r
                    newContents[index].column = c
                    newContents[index].save()
                }
                index += 1
            }
        }
        for content in deletedContents {
            content.delete()
        }
        save()
        contents = getContents(id: id)
    }

    static func createNewBoard(name: String, rows: Int, columns: Int, userId: Int) -> Board {
        var boardId: Int = -1
        let s = BoardState.db?.executeQuery("select seq from sqlite_sequence where name = 'board'", withArgumentsIn: []);
        if s?.next() != nil {
            boardId = s?.long(forColumnIndex: 0) ?? -1
        }
        s?.close()
        boardId += 1
        BoardState.db?.executeUpdate("insert into board (iphone_board_id,board_name,board_rows,board_clms,create_date,update_date,user_id, web_board_id,sort1,sort2,sort3) values(?,?,?,?,current_timestamp,current_timestamp,?, 0,0,0,0)", withArgumentsIn: [boardId, name, rows, columns, userId])
        let b = Board().setId(UInt(boardId), nil)
        return b;
    }
    
    static func createNewBoard(name: String, words: [String], userId: Int) throws -> Board {
        if words.count == 0 {
            throw "Must have a list of words"
        }
        let columns = Int(round(sqrt(Double(words.count))))
        let rows = Int(round(Double(words.count / columns)))
        let board = Board.createNewBoard(name: name, rows: rows, columns: columns, userId: userId)
        let contents = board.getContents(id: board.id)
        for i in 0..<words.count {
            contents[i].name = words[i]
            contents[i].save()
        }
        return board
    }
    
    static func createNewBoard(name: String, words: [WordWithDefinition], userId: Int, colorKey: String) throws -> Board {
        if words.count == 0 {
            throw "Must have a list of words"
        }
        var wordDictionary: [String:PartOfSpeech] = [:]
        for i in 0..<words.count {
            wordDictionary.updateValue(PartOfSpeech(word: words[i].Value, partOfSpeech: words[i].cat, unInflected: words[i].unInfl), forKey: words[i].Value + words[i].cat)
        }
        let columns = Int(round(sqrt(Double(wordDictionary.count))))
        var rows = Int(round(Double(wordDictionary.count / columns)))
        if columns * rows < wordDictionary.count {
            rows += 1
        }
        let board = Board.createNewBoard(name: name, rows: rows, columns: columns, userId: userId)
        let contents = board.getContents(id: board.id)
        let keys = Array(wordDictionary.keys)
        for i in 0..<keys.count {
            contents[i].name = wordDictionary[keys[i]]?.word ?? ""
            let cat = wordDictionary[keys[i]]?.partOfSpeech ?? ""
            let unInflected = wordDictionary[keys[i]]?.unInflected ?? ""
            if cat == "adv" {
                contents[i].setBackgroundColor(value: 8)
            }
            else if cat == "adj" {
                contents[i].setBackgroundColor(value: 8)
            }
            else if cat == "noun" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
            }
            else if cat == "nc" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
            }
            else if cat == "ncpred" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
            }
            else if cat == "np" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
            }
            else if cat == "pronoun" {
                if unInflected == "it" {
                    contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
                }
                else if unInflected == "those" {
                    contents[i].setBackgroundColor(value: colorKey == "0" ? 12 : 10)
                }
                else {
                    contents[i].setBackgroundColor(value: 10)
                }
            }
            else if cat == "verb" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 7 : 6)
            }
            else if cat == "v" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 7 : 6)
            }
            else if cat == "aux" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 7 : 6)
            }
            else if cat == "preposition" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 4 : 7)
            }
            else if cat == "prep" {
                contents[i].setBackgroundColor(value: colorKey == "0" ? 4 : 7)
            }
            else {
                print("Unknown category: \(cat)");
            }
            contents[i].save()
        }
        return board
    }
}

