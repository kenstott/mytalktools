//
//  PhraseBar.swift
//  test
//
//  Created by Kenneth Stott on 1/25/23.
//

import Foundation

class PhraseBarState: NSObject, ObservableObject {
    
    @Published var userPhraseModeToggle = false
    @Published var contents = [Content]()
    @Published var speakingItem = 0
    @Published var autoErase = false
    @Published var animate: (Int) -> Void = {_ in }
    @Published var phraseBarAnimate = false
    @Published var ttsVoice = ""
    @Published var ttsVoiceAlternate = ""
    @Published var speechRate = 0.0
    @Published var voiceShape = 0.0
    
    var speak = Speak()
    
    func speakPhraseCallback(_ username: String, _ boardName: String) {
        let nextItem = speakingItem
        speakingItem = 0
        speakPhrases(username, boardName, nextItem)
    }
    
    func appendToContents(_ content: Content) {
        contents.append(content)
    }
    
    func replaceContents(_ contents: [Content]) {
        self.contents = contents
    }
    
    func convertToCodable(history: [[Content]]) -> [[LibraryContent]] {
        var results = [[LibraryContent]]()
        for contentRow in history {
            var row = [LibraryContent]()
            for content in contentRow {
                row.append(LibraryContent.convert(content))
            }
            results.append(row)
        }
        return results
    }
    
    func convertFromCodable(history: [[LibraryContent]]) -> [[Content]] {
        var results = [[Content]]()
        for contentRow in history {
            var row = [Content]()
            for content in contentRow {
                row.append(Content().copyLibraryContent(content))
            }
            results.append(row)
        }
        return results
    }
    
    func getPhraseHash(phrase: [Content]) -> String {
        var result = ""
        for content in phrase {
            result += String(content.id)
            result += content.name
        }
        return result
    }
    
    func updatePhraseHistory(username: String, boardName: String = "") {
        let key = "phraseHistory.\(username)\(boardName != "" ? "." + boardName : "")"
        var phraseHistory = getPhraseHistory(username, boardName)
        let hash = getPhraseHash(phrase: contents)
        phraseHistory.removeAll(where: { getPhraseHash(phrase: $0) == hash })
        phraseHistory.insert(contents, at: 0)
        let result = String(data: try! JSONEncoder().encode(convertToCodable(history: phraseHistory)), encoding: .utf8) ?? "[]"
        UserDefaults.standard.set(result, forKey: key)
    }
    
    func getPhraseHistory(_ username: String, _ boardName: String ) -> [[Content]] {
        let key = "phraseHistory.\(username)\(boardName != "" ? "." + boardName : "")"
        do {
            let result: [[LibraryContent]] = try JSONDecoder().decode([[LibraryContent]].self, from: Data((UserDefaults.standard.string(forKey: key) ?? "[]").utf8))
            return convertFromCodable(history: Array(result))
        } catch {
            return []
        }
    }
    
    func updatePhraseFavorite(username: String, boardName: String = "", phrase: [Content], value: Bool) {
        let key = "phraseFavorites.\(username)\(boardName != "" ? "." + boardName : "")"
        var phraseFavorites = getPhraseFavorites(username, boardName)
        let hash = getPhraseHash(phrase: phrase)
        if value {
            phraseFavorites.insert(hash, at: 0)
        } else {
            phraseFavorites.removeAll(where: { $0 == hash })
        }
        let result = String(data: try! JSONEncoder().encode(phraseFavorites), encoding: .utf8) ?? "[]"
        UserDefaults.standard.set(result, forKey: key)
    }
    
    func getPhraseFavorites(_ username: String, _ boardName: String ) -> [String] {
        let key = "phraseFavorites.\(username)\(boardName != "" ? "." + boardName : "")"
        do {
            let result: [String] = try JSONDecoder().decode([String].self, from: Data((UserDefaults.standard.string(forKey: key) ?? "[]").utf8))
            return result
        } catch {
            return []
        }
    }
    
    func speakPhrases(_ username: String, _ boardName: String, _ item: Int = 0) {
        updatePhraseHistory(username: username, boardName: boardName)
        if self.contents.count > item {
            self.animate(item)
            speakingItem = item + 1
            self.contents[item].voice(speak, ttsVoice: ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate, speechRate: speechRate, voiceShape: voiceShape, callback: { self.speakPhraseCallback(username, boardName)})
        } else if autoErase {
            self.contents.removeAll()
        } else if phraseBarAnimate {
            self.animate(0)
        }
        
    }
}
