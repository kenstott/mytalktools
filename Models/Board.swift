import Foundation
import SwiftUI
import FMDB

func getString(id: Int, column: String, defaultValue: String = "") -> String {
    var result: String = defaultValue
    let s = DataWrapper.db!.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        result = s?.string(forColumnIndex: 0) ?? defaultValue
    }
    s?.close()
    return result
}

func getInt(id: Int, column: String, defaultValue: Int = -1) -> Int {
    var result: Int = defaultValue
    let s = DataWrapper.db!.executeQuery("SELECT \(column) FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        result = s?.long(forColumnIndex: 0) ?? defaultValue
    }
    s?.close()
    return result
}

private func getContent(id: Int) -> [Content] {
    var result: [Content] = []
    let s = DataWrapper.db!.executeQuery("SELECT iphone_content_id FROM content WHERE board_id = ?", withArgumentsIn: [id]) ?? FMResultSet();
    while s.next() {
        result.append(Content().setId(s.long(forColumnIndex: 0)))
    }
    s.close()
    return result;
}

private func getSort(id: Int) -> [Int] {
    var sort: [Int] = [0,0,0]
    let s = DataWrapper.db!.executeQuery("SELECT sort1, sort2, sort3 FROM board WHERE iphone_board_id = ?", withArgumentsIn: [id]);
    if s?.next() != nil {
        sort[0] = s?.long(forColumnIndex: 0) ?? 0
        sort[1] = s?.long(forColumnIndex: 1) ?? 0
        sort[2] = s?.long(forColumnIndex: 2) ?? 0
    }
    s?.close()
    return sort
}

class Board: Identifiable, ObservableObject {
    
    @Published var content: [Content] = []
    @Published var columns: Int = 0
    @Published var rows: Int = 0
    @Published var userId: Int = -1
    @Published var name: String = ""
    @Published var sort: [Int] = [0,0,0]
    @Published var id: Int = 0
    
    func setId(_ id: Int) {
        self.id = id;
        self.content = getContent(id: id)
        self.columns = getInt(id: id, column: "board_clms", defaultValue: -1)
        self.rows = getInt(id: id, column: "board_rows", defaultValue: -1)
        self.name = getString(id: id, column: "board_name", defaultValue: "Unknown")
        self.userId = getInt(id: id, column: "user_id", defaultValue: -1)
        self.sort = getSort(id: id)
    }
}

