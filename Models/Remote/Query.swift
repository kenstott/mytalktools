//
//  Query.swift
//  test
//
//  Created by Kenneth Stott on 1/29/23.
//

import Foundation

struct QueryInput: Decodable, Encodable {
    var query: String
    var site: String
}

struct QueryResult: Decodable, Encodable {
    var txt: String?
}

struct Query: Decodable, Encodable {
    var d: String
    var dd: [QueryResult] {
        get {
            return getResults(json: self.d)
        }
    }
}

func getResults(json: String) -> Array<QueryResult> {
    let jsonData = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    do {
        let result = try decoder.decode(Array<QueryResult>.self, from: jsonData)
        return result
    } catch {
        return []
    }
}

func professionalBoardNames(userid: String) -> String { return "SELECT DISTINCT mytalk_content.txt FROM  mytalk_device INNER JOIN mytalk_board_mytalk_content ON mytalk_device.board_id = mytalk_board_mytalk_content.board_id INNER JOIN mytalk_content ON mytalk_board_mytalk_content.content_id = mytalk_content.content_id WHERE (mytalk_device.user_id = '\(userid)') AND (mytalk_content.txt <> '') AND (mytalk_content.child_board_id <> 0) ORDER BY mytalk_content.txt" }




