import Foundation
import SwiftUI
import FMDB

func getString(id: Int, column: String, defaultValue: String = "") -> String {
    var result: String = defaultValue
    let s = GlobalState.db!.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        result = s?.string(forColumnIndex: 0) ?? defaultValue
    }
    s?.close()
    return result
}

func getInt(id: Int, column: String, defaultValue: Int = -1) -> Int {
    var result: Int = defaultValue
    let s = GlobalState.db!.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        result = s?.long(forColumnIndex: 0) ?? defaultValue
    }
    s?.close()
    return result
}

private func getContents(id: Int) -> [Content] {
    var result: [Content] = []
    let s = GlobalState.db!.executeQuery("SELECT iphone_content_id FROM content WHERE board_id = ?", withArgumentsIn: [id]) ?? FMResultSet();
    while s.next() {
        result.append(Content().setId(s.long(forColumnIndex: 0)))
    }
    s.close()
    return result;
}

private func getSort(id: Int) -> [Int] {
    var sort: [Int] = [0,0,0]
    let s = GlobalState.db!.executeQuery("SELECT sort1, sort2, sort3 FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        sort[0] = s?.long(forColumnIndex: 0) ?? 0
        sort[1] = s?.long(forColumnIndex: 1) ?? 0
        sort[2] = s?.long(forColumnIndex: 2) ?? 0
    }
    s?.close()
    return sort
}

class Board: Hashable, Identifiable, ObservableObject, Equatable {
    
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
    
    @Published var contents: [Content] = []
    @Published var filteredContents: [Content] = []
    @Published var columns: Int = 0
    @Published var rows: Int = 0
    @Published var userId: Int = -1
    @Published var name: String = ""
    @Published var sort: [Int] = [0,0,0]
    @Published var id: Int = 0
    
    init() {
        columns = 0
    }
    
    func setId(_ id: Int) -> Board {
        self.id = id;
        self.contents = getContents(id: id)
        self.columns = getInt(id: id, column: "board_clms", defaultValue: -1)
        self.rows = getInt(id: id, column: "board_rows", defaultValue: -1)
        self.name = getString(id: id, column: "board_name", defaultValue: "Unknown")
        self.userId = getInt(id: id, column: "user_id", defaultValue: -1)
        self.sort = getSort(id: id)
        calcCellSizes()
        sortContent()
        self.filteredContents = self.contents.filter { $0.externalUrl != "x" }
        return self
    }
    
    func content(_ id: Int) -> Content? {
        if let i = contents.firstIndex(where: { $0.id == id }) {
            return contents[i]
        }
        return nil
    }
    
    func defaultSortContent() -> [Content] {
        contents.sorted(by: { ( $0.row + 1 ) * ( $0.column + 1 ) < ( $1.row + 1 ) * ( $1.column + 1 )  })
    }
    
    func sortContent() {
        contents = contents.sorted(by: { ( $0.row + 1 ) * ( $0.column + 1 ) < ( $1.row + 1 ) * ( $1.column + 1 )  })
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
    
    func swap(id1: Int, id2: Int) -> Bool {
        let content1 = contents.first(where: {$0.id == id1})
        let content2 = contents.first(where: {$0.id == id2})
        if content1 != nil && content2 != nil {
            let row = content1!.row
            let column = content1!.column
            content1!.row = content2!.row
            content1!.column = content2!.column
            content2!.row = row
            content2!.column = column
            sortContent()
            return true
        }
        return false
    }
}

