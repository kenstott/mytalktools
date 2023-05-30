//
//  WordVariants.swift
//  test
//
//  Created by Kenneth Stott on 5/28/23.
//

import Foundation

struct Word: Encodable, Decodable {
    var word: String
}

struct WordVariantList: Encodable, Decodable {
    var d: [String]
}
class WordVariants {

    private var getWordVariants = Network<WordVariantList, Word>(service: "WordVariations", host: "https://www.mytalktools.com/dnn/lexicon.asmx")
    
    func findWordVariants(_ word: String) async throws -> [String]? {
        return (try await getWordVariants.execute(params: Word(word: word)))!.d
    }
}
