//
//  BoardSortOrder.swift
//  test
//
//  Created by Kenneth Stott on 4/29/23.
//

import SwiftUI

struct TypePhrase: View {
    
    enum FocusedField {
        case phrase
    }
    
    var done: ((String) -> Void)? = nil
    var cancel:  (() -> Void)? = nil
    @EnvironmentObject var speak: Speak
    @State var phrase = ""
    @State var history: [String] = []
    @State var historyPointer: Int?
    @FocusState private var focusedField: FocusedField?
    @SceneStorage("TypePhrase.history") private var historyState: String = "[]"
    @AppStorage("SpeechRate") var speechRate: Double = 200
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("PhraseMode") var phraseMode = "0"
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var phraseBarState: PhraseBarState
    
    func jsonEncode(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    func jsonDecode(from: String) -> [String] {
        do {
            return try JSONSerialization.jsonObject(with: Data(from.utf8)) as! [String]
        } catch _ {
            return []
        }
    }
    
    func speakPhrase() {
        if (history.count == 0) {
            history = jsonDecode(from: historyState)
        }
        history.removeAll(where: {$0 == phrase})
        history.append(phrase)
        historyState = jsonEncode(from: history) ?? "[]"
        if phraseMode == "1" {
            let content = Content()
            content.name = phrase
            phraseBarState.contents.append(content)
        } else {
            speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
//                print("Completed")
            }
            var alternate: Bool? = false
            speak.utter(phrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate)
        }
    }

    init(done: @escaping (String) -> Void, cancel: @escaping () -> Void) {
        self.done = done
        self.cancel = cancel
    }
    var body: some View {
        NavigationView {
            HStack {
                Form {
                    TextEditor(text: $phrase)
                        .textInputAutocapitalization(.none)
                        .focused($focusedField, equals: .phrase)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                HStack {
                                    Button {
                                        phrase = ""
                                    } label: {
                                        Label(LocalizedStringKey("Delete"), systemImage: "trash")
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                    Spacer()
                                    Button {
//                                        print("Speak")
                                        speakPhrase()
                                    } label: {
                                        Label(LocalizedStringKey("Speak"), systemImage: "bubble.right")
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                    Spacer()
                                    Button(action: {
                                        speakPhrase()
                                        dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "bubble.right")
                                            Text(LocalizedStringKey(" & Exit"))
                                        }
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                    Spacer()
                                    Button {
                                        print("History")
                                    } label: {
                                        Label(LocalizedStringKey("History"), systemImage: "list.bullet")
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                    Spacer()
                                    Button {
//                                        print("Previous")
                                        if (history.count == 0) {
                                            history = jsonDecode(from: historyState)
                                        }
                                        guard history.count == 0 else {
                                            if historyPointer == nil {
                                                historyPointer = 0
                                            }
                                            else {
                                                historyPointer = historyPointer! + 1
                                                if historyPointer! == history.count {
                                                    historyPointer = 0
                                                }
                                            }
                                            phrase = history[historyPointer!]
                                            return
                                        }
                                    } label: {
                                        Label(LocalizedStringKey("Previous"), systemImage: "arrow.backward.square")
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                    Button {
//                                        print("Next")
                                        if (history.count == 0) {
                                            history = jsonDecode(from: historyState)
                                        }
                                        guard history.count == 0 else {
                                            if historyPointer == nil {
                                                historyPointer = history.count - 1
                                            }
                                            else {
                                                historyPointer = historyPointer! - 1
                                                if historyPointer! < 0 {
                                                    historyPointer = history.count - 1
                                                }
                                            }
                                            phrase = history[historyPointer!]
                                            return
                                        }
                                    } label: {
                                        Label(LocalizedStringKey("Next"), systemImage: "arrow.forward.square")
                                    }.buttonStyle(.bordered)
                                        .controlSize(.small)
                                }
                            }
                        }
                }
                .onAppear {
                    focusedField = .phrase
                }
                .navigationBarTitle("\(Locale.current.languageCode ?? "Unknown")-\(Locale.current.regionCode ?? "Unknown")", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            speakPhrase()
                            dismiss()
                            done!(phrase)
                        } label: {
                            HStack {
                                Image(systemName: "bubble.right")
                                Text(LocalizedStringKey(" & Exit"))
                            }
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            cancel!()
                        } label: {
                            Text(LocalizedStringKey("Cancel"))
                        }
                        
                    }
                }
            }
        }
    }
}

