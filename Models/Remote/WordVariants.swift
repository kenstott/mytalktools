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

struct WordWithDefinition: Encodable, Decodable {
    var __type: String
    var cat: String
    var cit: String
    var eui: String
    var infl: String
    var type: String
    var unInfl: String
    var Value: String
}

struct WordVariantListWithDefinitions: Encodable, Decodable {
    var d: [WordWithDefinition]
}

struct PartOfSpeech: Hashable {
    var word: String
    var partOfSpeech: String
    var unInflected: String
}

class WordVariants {
    
    private var getWordVariants = Network<WordVariantList, Word>(service: "WordVariations", host: "https://www.mytalktools.com/dnn/lexicon.asmx")
    
    private var getWordVariantsWithDefinitions = Network<WordVariantListWithDefinitions, Word>(service: "PartOfSpeechWithDefinitions", host: "https://www.mytalktools.com/dnn/lexicon.asmx")
    
    func findWordVariants(_ word: String) async throws -> [String]? {
        return (try await getWordVariants.execute(params: Word(word: word)))!.d
    }

    func findWordVariantsWithDefinitions(_ word: String) async throws -> [WordWithDefinition]? {
        return (try await getWordVariantsWithDefinitions.execute(params: Word(word: word)))!.d
    }

}
