//
//  EditCell.swift
//  test
//
//  Created by Kenneth Stott on 4/1/23.
//

import SwiftUI
import Contacts

class EditableContent: ObservableObject {
    
    @Published var initialized = false
    @Published var content: Content = Content()
    @Published var contentType: ContentType = .imageSoundName
    @Published var isOpaque: Bool = false
    @Published var image: UIImage = UIImage()
    @Published var name: String = ""
    @Published var negate: Bool = false
    @Published var positive: Bool = false
    @Published var imageUrl: String = ""
    @Published var soundUrl: String = ""
    @Published var boardId: Int = 0
    @Published var childBoard: UInt = 0
    @Published var childBoardId: UInt = 0
    @Published var childBoardLink: UInt = 0
    @Published var includeRepeatedCells: Bool = false
    @Published var popupStyleBoard: Bool = false
    @Published var fontSize: Int = 0
    @Published var foregroundColor: Int = 0
    @Published var backgroundColor: Int = 0
    @Published var cellSize: Int = 0
    @Published var doNotZoomPics: Bool = false
    @Published var zoom: Bool = false
    @Published var doNotAddToPhraseBar: Bool = false
    @Published var hidden: Bool = false
    @Published var ttsSpeech: String = ""
    @Published var ttsSpeechPrompt: String = ""
    @Published var alternateTTSVoice: Bool = false
    @Published var alternateTTS: String = ""
    @Published var externalUrl: String = ""
    @Published var editedContent: Content = Content()
    @Published var scheduleCommand = ""
    
    func copy(content: Content) {
        self.content = content
        self.name = content.name
        self.isOpaque = content.isOpaque
        self.image = content.image
        self.imageUrl = content.imageURL
        self.negate = content.negate
        self.positive = content.positive
        self.soundUrl = content.soundURL
        self.childBoard = content.linkId
        self.childBoardId = content.childBoardId
        self.childBoardLink = content.childBoardLink
        self.includeRepeatedCells = content.repeatBoard
        self.popupStyleBoard = content.popupStyleChildBoard
        self.fontSize = content.fontSize
        self.foregroundColor = content.foregroundColor
        self.backgroundColor = content.backgroundColor
        self.editedContent = content.copy(id: content.id)
        self.cellSize = content.cellSize
        self.doNotZoomPics = content.doNotZoomPics
        self.zoom = content.zoom
        self.doNotAddToPhraseBar = content.doNotAddToPhraseBar
        self.hidden = content.hidden
        self.ttsSpeech = content.ttsSpeech
        self.ttsSpeechPrompt = content.ttsSpeechPrompt
        self.alternateTTSVoice = content.alternateTTSVoice
        self.alternateTTS = content.alternateTTS
        self.externalUrl = content.externalUrl
        if content.externalUrl.starts(with: "mtschedule") {
            self.scheduleCommand = content.externalUrl
        }
        self.boardId = content.boardId
        switch (content.contentType) {
        case .goBack: self.contentType = .goBack
        case .goHome: self.contentType = .goHome
        default: self.contentType = .imageSoundName
        }
        self.editedContent.contentType = contentType
        self.editedContent.boardId = content.boardId
        self.initialized = true
    }
    
    func copy(content: EditableContent) {
        self.content = content.content
        self.name = content.name
        self.isOpaque = content.isOpaque
        self.image = content.image
        self.imageUrl = content.imageUrl
        self.negate = content.negate
        self.positive = content.positive
        self.soundUrl = content.soundUrl
        self.childBoard = content.childBoard
        self.childBoardId = content.childBoardId
        self.childBoardLink = content.childBoardLink
        self.includeRepeatedCells = content.includeRepeatedCells
        self.popupStyleBoard = content.popupStyleBoard
        self.fontSize = content.fontSize
        self.foregroundColor = content.foregroundColor
        self.backgroundColor = content.backgroundColor
        self.editedContent = content.editedContent
        self.cellSize = content.cellSize
        self.doNotZoomPics = content.doNotZoomPics
        self.zoom = content.zoom
        self.doNotAddToPhraseBar = content.doNotAddToPhraseBar
        self.hidden = content.hidden
        self.ttsSpeech = content.ttsSpeech
        self.ttsSpeechPrompt = content.ttsSpeechPrompt
        self.alternateTTSVoice = content.alternateTTSVoice
        self.alternateTTS = content.alternateTTS
        self.externalUrl = content.externalUrl
        if content.externalUrl.starts(with: "mtschedule") {
            self.scheduleCommand = content.externalUrl
        }
        self.boardId = content.boardId
        switch (content.contentType) {
        case .goBack: self.contentType = .goBack
        case .goHome: self.contentType = .goHome
        default: self.contentType = .imageSoundName
        }
        self.editedContent.contentType = contentType
        self.editedContent.boardId = content.boardId
        self.initialized = true
    }
}

struct EditCell: View {
    
    enum ActiveSheet {
        case Main
        case IMDB
        case AppLinkCreated
        case MyTalk
        case Pandora
        case Facebook
        case Contacts
        case Facetime
        case Skype
        case Image
        case Sound
        case Video
        case ChildBoard
        case NewBoard
    }
    
    enum FilePickerType {
        case image
        case sound
        case childBoard
        case video
    }
    
    @EnvironmentObject var userState: User
    @EnvironmentObject var speak: Speak
    @EnvironmentObject var media: Media
    @EnvironmentObject var boardState: BoardState
    @AppStorage("PhraseBarAnimate") var phraseBarAnimate = false
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("SpeechRate") var speechRate: Double = 200
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    @AppStorage("ColorKey") var colorKey = "1"
    
    @StateObject private var editableContent = EditableContent()
    
    @State private var content = Content()
    @State private var contentId: Int
    @State private var hasBuffer: Bool = false
    @State private var showFilePicker = false
    @State private var filePickerType: FilePickerType = .image
    @State private var filePickerTYpes: [UTType] = [.image]
    @State private var mediaTypes: [UTType] = [.image]
    @State private var testExternalUrl: String = ""
    @State private var showIntegrationIdeas: Bool = false
    @State private var activeSheet: ActiveSheet = .Main
    @State private var showPandoraArtist = false
    @State private var pandoraArtist = ""
    @State private var showPandoraSong = false
    @State private var pandoraSong = ""
    @State private var showDirections = false
    @State private var address = ""
    @State private var showEmail = false
    @State private var showAppleID = false
    @State private var showFacetimeEmail = false
    @State private var showPhrase = false
    @State private var ttsPhrase = ""
    @State private var showPhoneNumber = false
    @State private var showContact = false
    @State private var showContacts = false
    @State private var facetimeID = ""
    @State private var contactName = ""
    @State private var showSkypePhoneNumber = false
    @State private var skypePhoneNumber = ""
    @State private var showSkypeVideo = false
    @State private var skypeVideo = ""
    @State private var showSMS = false
    @State private var smsPhoneNumber = ""
    @State private var showTelephone = false
    @State private var telephonePhoneNumber = ""
    @State private var showPhotoLibrary = false
    @State private var showCamera = false
    @State private var showVideoCamera = false
    @State private var showRecordAudio = false
    @State private var cameraURL: String = ""
    @State private var showShareSheet = false
    @State private var showWebBrowser = false
    @State private var showWebImageSearch = false
    @State private var showCropTool = false
    @State public var sharedItems : [Any] = []
    @State private var showLibraries = false
    @State private var libraryFilter: Filter = .all
    @State private var showContactPicker = false
    @State private var contact: CNContact = CNContact()
    @State private var showNewSimpleBoard = false
    @State private var newRows = 3
    @State private var newColumns = 3
    @State private var showLocationPicker = false
    @State private var showScheduler = false
    
    private var save: ((Content) -> Void)? = nil
    private var cancel:  (() -> Void)? = nil
    private let wordVariants = WordVariants()
    
    
    init(content: Content, save: @escaping (Content) -> Void, cancel: @escaping () -> Void) {
        self.contentId = content.id
        self.save = save
        self.cancel = cancel
    }
    
    var body: some View {
        UITextField.appearance().clearButtonMode = .always
        print(editableContent.imageUrl)
        return NavigationView {
            HStack {
                Form {
                    Section {
                        Picker(selection: $editableContent.contentType, label: Text(LocalizedStringKey("Cell Type"))) {
                            Text(LocalizedStringKey("Media")).tag(ContentType.imageSoundName)
                            Text(LocalizedStringKey("Go Home")).tag(ContentType.goHome)
                            Text(LocalizedStringKey("Go Back")).tag(ContentType.goBack)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    } header: {
                        Text(LocalizedStringKey("Type"))
                    }
                    if editableContent.contentType != .goHome && editableContent.contentType != .goBack {
                        Section {
                            TextField(text: $editableContent.name, prompt: Text(LocalizedStringKey("Cell Text")))
                            {
                                Text(LocalizedStringKey("Text"))
                            }
                        } header: {
                            Text(LocalizedStringKey("Text"))
                        }
                        .textFieldStyle(.roundedBorder)
                        Section {
                            VStack {
                                if editableContent.imageUrl != "" {
                                    Toggle(isOn: $editableContent.isOpaque) {
                                        Text(LocalizedStringKey("Opaque")).frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                HStack {
                                    VStack(alignment :.leading, spacing: 10) {
                                        Button {
                                            showIntegrationIdeas = true
                                            activeSheet = .Image
                                        } label: {
                                            Label(editableContent.imageUrl != "" ? LocalizedStringKey("Swap") : LocalizedStringKey("Add"), systemImage: editableContent.imageUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                        }
                                        if editableContent.imageUrl != "" {
                                            Button {
                                                showCropTool = true
                                                
                                            } label: {
                                                Label(LocalizedStringKey("Crop"), systemImage: "crop").labelStyle(.iconOnly)
                                            }
                                            Button(role: .destructive) {
                                                editableContent.imageUrl = ""
                                            } label: {
                                                Label(LocalizedStringKey("Delete"), systemImage: "trash").labelStyle(.iconOnly)
                                            }
                                            Button {
                                                editableContent.image = boardState.copyBuffer.image
                                                editableContent.imageUrl = boardState.copyBuffer.imageUrl
                                            } label: {
                                                Label(LocalizedStringKey("Paste"), systemImage: "doc.on.clipboard").labelStyle(.iconOnly)
                                            }.disabled(boardState.copyBuffer.imageUrl == "")
                                            Button {
                                                editableContent.image = editableContent.image.rotate(radians: 1.57079633)!
                                                if let data = editableContent.image.pngData() {
                                                    var (_, filename, _) = Media.splitFileName(str: editableContent.imageUrl)
                                                    filename = "\(filename)_r"
                                                    var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                        .first?.appendingPathComponent(userState.username)
                                                        .appendingPathComponent("Private Library")
                                                        .appendingPathComponent(filename)
                                                        .appendingPathExtension("png")
                                                    while FileManager.default.fileExists(atPath: fileURL!.path) {
                                                        filename = "\(filename)_r"
                                                        fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                            .first?.appendingPathComponent(userState.username)
                                                            .appendingPathComponent("Private Library")
                                                            .appendingPathComponent(filename)
                                                            .appendingPathExtension("png")
                                                    }
                                                    try? data.write(to: fileURL!)
                                                    editableContent.imageUrl = "\(userState.username)/Private Library/\(filename).png"
                                                }
                                            } label: {
                                                Label(LocalizedStringKey("Rotate"), systemImage: "rotate.right").labelStyle(.iconOnly)
                                            }
                                            Button {
                                                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                    .first?.appendingPathComponent(editableContent.imageUrl)
                                                guard let image = UIImage(contentsOfFile: fileURL!.path) else { return }
                                                let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                                                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                                            } label: {
                                                Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                                            }
                                        }
                                    }.buttonStyle(BorderlessButtonStyle())
                                    Spacer()
                                    if editableContent.imageUrl != "" {
                                        VStack {
                                            Toggle(isOn: $editableContent.negate) {
                                                Text(LocalizedStringKey("No")).frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                            Toggle(isOn: $editableContent.positive) {
                                                Text(LocalizedStringKey("Yes")).frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                        }
                                        Spacer()
                                        ZStack {
                                            Image(uiImage: editableContent.image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .background(editableContent.isOpaque ? .white : .clear)
                                                .padding(0)
                                                .border(.gray, width: 1)
                                            if editableContent.negate {
                                                NegateView()
                                            } else if editableContent.positive {
                                                PositiveView()
                                            }
                                        }.frame(width: 160, height: 160)
                                    }
                                }
                            }
                        } header: {
                            Text(LocalizedStringKey("Image"))
                        }
                        if editableContent.soundUrl == "" || !editableContent.content.isVideo(soundURL: editableContent.soundUrl) {
                            Section {
                                HStack {
                                    Button {
                                        showIntegrationIdeas = true
                                        activeSheet = .Sound
                                    } label: {
                                        Label(editableContent.soundUrl != "" ? LocalizedStringKey("Swap") : LocalizedStringKey("Add"), systemImage: editableContent.soundUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    if editableContent.soundUrl != "" {
                                        Button(role: .destructive) {
                                            editableContent.soundUrl = ""
                                        } label: {
                                            Label(LocalizedStringKey("Delete"), systemImage: "trash").labelStyle(.iconOnly)
                                        }
                                        Spacer()
                                        Button {
                                            print("Share")
                                        } label: {
                                            
                                            Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                                        }
                                        Spacer()
                                        Button {
                                            print("Play")
                                        } label: {
                                            
                                            Label(LocalizedStringKey("Share"), systemImage: "play").labelStyle(.iconOnly)
                                        }
                                    }
                                }.buttonStyle(BorderlessButtonStyle())
                            } header: {
                                Text(LocalizedStringKey("Sound"))
                            }
                        }
                        if editableContent.soundUrl == "" || editableContent.content.isVideo(soundURL: editableContent.soundUrl) {
                            Section {
                                HStack {
                                    Button {
                                        showIntegrationIdeas = true
                                        activeSheet = .Video
                                    } label: {
                                        Label(editableContent.soundUrl != "" ? LocalizedStringKey("Swap") : LocalizedStringKey("Add"), systemImage: editableContent.soundUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    if editableContent.soundUrl != "" {
                                        Button(role: .destructive) {
                                            editableContent.soundUrl = ""
                                        } label: {
                                            Label(LocalizedStringKey("Delete"), systemImage: "trash").labelStyle(.iconOnly)
                                        }
                                        Spacer()
                                        Button {
                                            print("Share")
                                        } label: {
                                            
                                            Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                                        }
                                        Spacer()
                                        Button {
                                            print("Play")
                                        } label: {
                                            
                                            Label(LocalizedStringKey("Share"), systemImage: "play").labelStyle(.iconOnly)
                                        }
                                    }
                                }.buttonStyle(BorderlessButtonStyle())
                            } header: {
                                Text(LocalizedStringKey("Video"))
                            }
                        }
                        Section {
                            if editableContent.childBoard > 0 {
                                VStack {
                                    Toggle(isOn: $editableContent.includeRepeatedCells) {
                                        Text(LocalizedStringKey("Include Repeated Cells"))
                                    }
                                    Toggle(isOn: $editableContent.popupStyleBoard) {
                                        Text(LocalizedStringKey("Popup Style Board"))
                                    }
                                }
                            }
                            HStack {
                                Button {
                                    showIntegrationIdeas = true
                                    activeSheet = .ChildBoard
                                } label: {
                                    Label(editableContent.childBoard > 0 ? LocalizedStringKey("Swap") : LocalizedStringKey("Add"), systemImage: editableContent.childBoard > 0 ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                }
                                Spacer()
                                if editableContent.childBoard > 0 {
                                    Button(role: .destructive) {
                                        editableContent.childBoardId = 0
                                        editableContent.childBoardLink = 0
                                    } label: {
                                        Label(LocalizedStringKey("Delete"), systemImage: "trash").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    Button {
                                        showLocationPicker = true
                                    } label: {
                                        
                                        Label(LocalizedStringKey("Location"), systemImage: "mappin.and.ellipse").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    Button {
                                        showScheduler = true
                                    } label: {
                                        
                                        Label(LocalizedStringKey("Schedule"), systemImage: "clock").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    Button {
                                        print("Share")
                                    } label: {
                                        
                                        Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    Button {
                                        print("Play")
                                    } label: {
                                        
                                        Label(LocalizedStringKey("Share"), systemImage: "play").labelStyle(.iconOnly)
                                    }
                                }
                            }.buttonStyle(BorderlessButtonStyle())
                        } header: {
                            Text(LocalizedStringKey("Child Board"))
                        }
                        Section {
                            VStack {
                                HStack {
                                    Text(LocalizedStringKey("Font Size"))
                                    Stepper(value: $editableContent.fontSize,
                                            in: 0...50,
                                            step: 1) {
                                        if editableContent.fontSize != 0 {
                                            Text("\(editableContent.fontSize) \(NSLocalizedString("pixels", comment: ""))")
                                                .italic()
                                                .font(.system(size: 14))
                                        } else {
                                            Text(LocalizedStringKey("default size"))
                                                .italic()
                                                .font(.system(size: 14))
                                        }
                                    }
                                            .padding(5)
                                }
                                
                                Stepper(value: $editableContent.foregroundColor,
                                        in: 0...16,
                                        step: 1) {
                                    if editableContent.foregroundColor != Content.ForegroundColorMask.kfDefault.rawValue {
                                        Text(LocalizedStringKey("Foreground Color")).foregroundColor(Content.convertColor(value: editableContent.foregroundColor))
                                    } else {
                                        Text(LocalizedStringKey("default foreground color")).font(.system(size: 14))
                                    }
                                }
                                        .padding(5)
                                Stepper(value: $editableContent.backgroundColor,
                                        in: 0...16,
                                        step: 1) {
                                    if editableContent.backgroundColor != Content.BackgroundColorMask.kNone.rawValue {
                                        Text(LocalizedStringKey("Background Color")).background(Content.convertBackgroundColor(value: editableContent.backgroundColor))
                                    } else  if editableContent.backgroundColor != Content.ForegroundColorMask.kfClear.rawValue {
                                        Text(LocalizedStringKey("transparent background color")).italic().font(.system(size: 14))
                                    } else {
                                        Text(LocalizedStringKey("default background color")).italic().font(.system(size: 14))
                                    }
                                }
                                        .padding(5)
                                HStack {
                                    Text(LocalizedStringKey("Cell Width"))
                                    Stepper(value: $editableContent.cellSize,
                                            in: 1...15,
                                            step: 1) {
                                        
                                        Text("\(editableContent.cellSize) \(editableContent.cellSize == 0 ? NSLocalizedString("column", comment: "") : NSLocalizedString("columns", comment: ""))").italic().font(.system(size: 14))
                                        
                                    }
                                            .padding(5)
                                }
                                
                                
                            }
                        } header: {
                            Text(LocalizedStringKey("Styles"))
                        }
                        Section {
                            VStack {
                                Toggle(LocalizedStringKey("Never Zoom"), isOn: $editableContent.doNotZoomPics)
                                Toggle(LocalizedStringKey("Always Zoom"), isOn: $editableContent.zoom)
                                Toggle(LocalizedStringKey("Do Not Add To Phrase Bar"), isOn: $editableContent.doNotAddToPhraseBar)
                                Toggle(LocalizedStringKey("Hide from User"), isOn: $editableContent.hidden)
                            }
                        } header: {
                            Text(LocalizedStringKey("Cell Touch"))
                        }
                        Section {
                            VStack {
                                HStack {
                                    TextField(LocalizedStringKey("TTS"), text: $editableContent.ttsSpeech)
                                    Button {
                                        print("Play")
                                    } label: {
                                        Label(LocalizedStringKey("Play"), systemImage: "play").labelStyle(.iconOnly)
                                    }
                                }
                                HStack {
                                    TextField(LocalizedStringKey("Prompt"), text: $editableContent.ttsSpeechPrompt)
                                    Button {
                                        print("Play")
                                    } label: {
                                        Label(LocalizedStringKey("Play"), systemImage: "play").labelStyle(.iconOnly)
                                    }
                                }
                                Toggle(LocalizedStringKey("Alternate TTS Voice"), isOn: $editableContent.alternateTTSVoice)
                            }
                        } header: {
                            Text(LocalizedStringKey("Text-to-Speech"))
                        }
                        Section {
                            HStack {
                                TextField(LocalizedStringKey("Tap + for ideas"), text: $editableContent.externalUrl)
                                Button {
                                    activeSheet = .Main
                                    showIntegrationIdeas = true
                                } label: {
                                    Label(LocalizedStringKey("Add Integration"), systemImage: "plus").labelStyle(.iconOnly)
                                }
                            }
                            
                        } header: {
                            Text(LocalizedStringKey("Integration and Automation"))
                        }
                    }
                }
                .navigationBarTitle(LocalizedStringKey("Edit Cell"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            save!(editableContent.editedContent)
                        } label: {
                            Text(LocalizedStringKey("Save"))
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            cancel!()
                        } label: {
                            Text(LocalizedStringKey("Cancel"))
                        }
                        
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            boardState.copyBuffer.copy(content: editableContent)
                            hasBuffer = true
                        } label: {
                            Label(LocalizedStringKey("Copy"), systemImage: "doc.on.doc").labelStyle(.iconOnly)
                        }
                        Spacer()
                        Button {
                            editableContent.copy(content: boardState.copyBuffer)
                        } label: {
                            Label(LocalizedStringKey("Paste"), systemImage: "doc.on.clipboard").labelStyle(.iconOnly)
                        }.disabled(!hasBuffer)
                        Spacer()
                        Button {
                            boardState.copyBuffer.copy(content: editableContent)
                            editableContent.copy(content: EditableContent())
                        } label: {
                            Label(LocalizedStringKey("Cut"), systemImage: "scissors").labelStyle(.iconOnly)
                        }
                        Spacer()
                        Button {
                            editableContent.copy(content: Content().setId(contentId))
                        } label: {
                            Label(LocalizedStringKey("Restore"), systemImage: "arrow.uturn.backward").labelStyle(.iconOnly)
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                        }
                    }
                }
                Spacer()
            }
            .onChange(of: contact) {
                newValue in
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID()).jpeg")
                try? contact.imageData?.write(to: tempURL)
                cameraURL = tempURL.path
            }
            .onChange(of: cameraURL) {
                newValue in
                if URL(string: newValue)?.containsVideo == true || URL(string: newValue)?.containsMovie == true  {
                } else if URL(string: newValue)?.containsAudio == true {
                    Task {
                        if (cameraURL.starts(with: "http")) {
                            editableContent.soundUrl = Media.truncateRemoteURL(URL(string: cameraURL)!)
                            await media.syncURL(url: URL(string: cameraURL)!)
                        } else {
                            let ext = URL(string: cameraURL)?.pathExtension
                            let fileURL = Media.generateFileName(str: editableContent.name, username: userState.username, ext: ext!)
                            FileManager.default.createFile(atPath: fileURL.path, contents: try Data(contentsOf: URL(string: cameraURL)!))
                            editableContent.soundUrl = Media.truncateLocalURL(fileURL)
                        }
                    }
                } else {
                    Task {
                        if cameraURL.starts(with: "http") {
                            if cameraURL.contains("UserUploads/") {
                                let (data, responseRaw) = try await URLSession.shared.data(from: URL(string: cameraURL)!)
                                let response = responseRaw as? HTTPURLResponse
                                if response!.statusCode == 200 {
                                    editableContent.image = UIImage(data: data)!
                                    editableContent.imageUrl = Media.truncateRemoteURL(URL(string: cameraURL)!)
                                    await media.syncURL(url: URL(string: cameraURL)!)
                                } else {
                                    print(response!.statusCode)
                                }
                            } else {
                                Task {
                                    let url = URL(string: cameraURL)
                                    DispatchQueue.global (qos:.userInitiated).async {
                                        let data = try? Data(contentsOf: url!)
                                        DispatchQueue.main.async {
                                            if let imageData = data {
                                                editableContent.image = UIImage(data: imageData)!
                                                let fileURL = Media.generateFileName(str: editableContent.name, username: userState.username, ext: "png")
                                                let scaledImage = ImageUtility.scaleAndRotateImage(editableContent.image, setWidth: 1000, setHeight: 0, setOrientation: editableContent.image.imageOrientation)
                                                let pngImageData = scaledImage!.pngData()
                                                FileManager.default.createFile(atPath: fileURL.path, contents: pngImageData)
                                                editableContent.imageUrl = Media.truncateLocalURL(fileURL)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            editableContent.image = UIImage(contentsOfFile: cameraURL)!
                            let fileURL = Media.generateFileName(str: editableContent.name, username: userState.username, ext: "png")
                            let scaledImage = ImageUtility.scaleAndRotateImage(editableContent.image, setWidth: 1000, setHeight: 0, setOrientation: editableContent.image.imageOrientation)
                            let pngImageData = scaledImage!.pngData()
                            FileManager.default.createFile(atPath: fileURL.path, contents: pngImageData)
                            editableContent.imageUrl = Media.truncateLocalURL(fileURL)
                        }
                    }
                }
            }
            .onChange(of: editableContent.scheduleCommand) {
                newValue in
                if newValue != "" {
                    editableContent.externalUrl = editableContent.scheduleCommand
                } else if editableContent.externalUrl.starts(with: "mtschedule") {
                    editableContent.scheduleCommand = editableContent.externalUrl
                }
            }
            .onChange(of: editableContent.alternateTTSVoice) {
                newValue in
                editableContent.editedContent.setAlternateTTSVoice(value: newValue)
            }
            .onChange(of: editableContent.ttsSpeechPrompt) {
                newValue in
                editableContent.editedContent.ttsSpeechPrompt = newValue
            }
            .onChange(of: editableContent.ttsSpeech) {
                newValue in
                editableContent.editedContent.ttsSpeech = newValue
            }
            .onChange(of: editableContent.externalUrl) {
                newValue in
                editableContent.editedContent.externalUrl = newValue
            }
            .onChange(of: editableContent.positive) {
                newValue in
                editableContent.editedContent.setPositive(value: newValue)
                if editableContent.positive {
                    editableContent.negate = false
                }
            }
            .onChange(of: editableContent.negate) {
                newValue in
                editableContent.editedContent.setNegate(value: newValue)
                if editableContent.negate {
                    editableContent.positive = false
                }
            }
            .onChange(of: editableContent.isOpaque) {
                newValue in
                editableContent.editedContent.setOpaque(value: newValue)
                print(newValue)
            }
            .onChange(of: editableContent.hidden) {
                newValue in
                editableContent.editedContent.setHidden(value: newValue)
            }
            .onChange(of: editableContent.doNotAddToPhraseBar) {
                newValue in
                editableContent.editedContent.doNotAddToPhraseBar = newValue
            }
            .onChange(of: editableContent.zoom) {
                newValue in
                editableContent.editedContent.zoom = newValue
            }
            .onChange(of: editableContent.doNotZoomPics) {
                newValue in
                editableContent.editedContent.doNotZoomPics = newValue
            }
            .onChange(of: editableContent.foregroundColor) {
                newValue in
                editableContent.editedContent.setColor(value: newValue)
            }
            .onChange(of: editableContent.backgroundColor) {
                newValue in
                editableContent.editedContent.setBackgroundColor(value: newValue)
            }
            .onChange(of: editableContent.fontSize) {
                newValue in
                editableContent.editedContent.fontSize = newValue
            }
            .onChange(of: editableContent.contentType) {
                newValue in
                editableContent.editedContent.contentType = newValue
            }
            .onChange(of: editableContent.childBoardId) {
                newValue in
                editableContent.editedContent.childBoardId = newValue
                editableContent.editedContent.childBoardLink = 0
                editableContent.childBoard = newValue
            }
            .onChange(of: editableContent.childBoardLink) {
                newValue in
                editableContent.editedContent.childBoardLink = newValue
                editableContent.editedContent.childBoardId = 0
                editableContent.childBoard = newValue
            }
            .onChange(of: editableContent.name) {
                newValue in
                editableContent.editedContent.name = newValue
            }
            .onChange(of: editableContent.imageUrl) {
                newValue in
                editableContent.editedContent.imageURL = newValue
            }
            .onChange(of: editableContent.soundUrl) {
                newValue in
                editableContent.editedContent.soundURL = newValue
            }
            .sheet(isPresented: $showContactPicker) {
                EmbeddedContactPicker(contact: $contact, predicate: NSPredicate(format: "imageDataAvailable == %@", argumentArray: [true]))
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(sourceType: .savedPhotosAlbum, mediaTypes: mediaTypes, selectedURL: $cameraURL)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera, mediaTypes: [.image], cameraCaptureMode: .photo, selectedURL: $cameraURL)
            }
            .sheet(isPresented: $showVideoCamera) {
                ImagePicker(sourceType: .camera, mediaTypes: [.movie], cameraCaptureMode: .video, selectedURL: $cameraURL)
            }
            .sheet(isPresented: $showRecordAudio) {
                RecordSound(cellText: $editableContent.name, filename: $editableContent.soundUrl)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: self.sharedItems)
            }
            .sheet(isPresented: $showWebBrowser) {
                WebBrowser(imageUrl: $cameraURL, cellText: $editableContent.name)
            }
            .sheet(isPresented: $showWebImageSearch) {
                ImageSearch(query: editableContent.name, imageUrl: $cameraURL)
            }
            .sheet(isPresented: $showCropTool) {
                CropTool(imageUrl: editableContent.imageUrl, outUrl: $cameraURL)
            }
            .sheet(isPresented: $showLibraries) {
                NavigableLibraryDialog(filter: libraryFilter, query: editableContent.name, selectedURL: $cameraURL)
            }
            .sheet(isPresented: $showLocationPicker) {
                NavigationView {
                    FindLocation(urlResult: $editableContent.externalUrl)
                }
            }
            .sheet(isPresented: $showScheduler) {
                NavigationView {
                    Schedule(urlResult: $editableContent.scheduleCommand)
                }
            }
            .sheet(isPresented: $showNewSimpleBoard) {
                NewSimpleBoard(rows: $newRows, columns: $newColumns) { cancelled in
                    if !cancelled {
                        editableContent.childBoardId = Board.createNewBoard(name: editableContent.editedContent.name, rows: newRows, columns: newColumns, userId: userState.id).id
                    }
                }
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: filePickerTYpes) { result in
            do {
                let tempURL = try result.get()
                switch(filePickerType) {
                case .image:
                    editableContent.imageUrl = Media.copyTempUrl(tempURL, username: userState.username) ?? ""
                    editableContent.image = Media.uiImageFromShortPath(editableContent.imageUrl)!
                case .video:
                    fallthrough
                case .sound:
                    editableContent.soundUrl = Media.copyTempUrl(tempURL, username: userState.username) ?? ""
                default: print("")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        .alert("Enter song name", isPresented: $showPandoraSong) {
            TextField("Enter song name", text: $pandoraSong)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "pandora:/createStation?song=\(pandoraSong.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Phrase", isPresented: $showPhrase) {
            TextField("Enter Phrase", text: $ttsPhrase).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                let fileURL = Media.generateFileName(str: editableContent.name, username: userState.username, ext: "wav")
                speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                    editableContent.soundUrl = "\(userState.username)/Private Library/\(fileURL.lastPathComponent)"
                }
                var alternate: Bool? = editableContent.alternateTTSVoice
                speak.utter(ttsPhrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate, fileURL: fileURL)
            })
            Button("Test", action: {
                speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                    DispatchQueue.main.async {
                        showPhrase = true
                    }
                }
                var alternate: Bool? = editableContent.alternateTTSVoice
                speak.utter(ttsPhrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate)
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Email", isPresented: $showFacetimeEmail) {
            TextField("Enter Email", text: $facetimeID).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "facetime://\(facetimeID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Skype Phone Number", isPresented: $showSkypePhoneNumber) {
            TextField("Enter Phone Number", text: $skypePhoneNumber).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "skype:\(Media.cleansePhoneNumber(skypePhoneNumber))"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter SMS Phone Number", isPresented: $showSMS) {
            TextField("Enter Phone Number", text: $smsPhoneNumber).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "sms:\(Media.cleansePhoneNumber(smsPhoneNumber))"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Telephone Number", isPresented: $showTelephone) {
            TextField("Enter Phone Number", text: $telephonePhoneNumber).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "tel:\(Media.cleansePhoneNumber(telephonePhoneNumber))"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Skype Name", isPresented: $showSkypeVideo) {
            TextField("Enter the Skype name", text: $skypeVideo).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "skype:\(skypeVideo.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")?call&video=true"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Phone Number", isPresented: $showPhoneNumber) {
            TextField("Enter Phone Number", text: $facetimeID).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "facetime://\(facetimeID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Contact Name", isPresented: $showContact) {
            TextField("Enter a name", text: $contactName).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "contact:/\(contactName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Comma-Separated Name List", isPresented: $showContacts) {
            TextField("Enter list", text: $contactName).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "contactsboard:/\(contactName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter Apple ID", isPresented: $showAppleID) {
            TextField("Enter Apple ID", text: $facetimeID).autocapitalization(.none).disableAutocorrection(true)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "facetime://\(facetimeID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Add Destination", isPresented: $showDirections) {
            TextField("Enter the address", text: $address)
                .autocapitalization(.none)
                .disableAutocorrection(false)
            Button("OK", action: {
                let addressComponent = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "";
                activeSheet = .AppLinkCreated
                testExternalUrl = "maps://app?daddr=\(addressComponent)&saddr=Current+Location"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .alert("Enter artist name", isPresented: $showPandoraArtist) {
            TextField("Enter artist name", text: $pandoraArtist)
            Button("OK", action: {
                activeSheet = .AppLinkCreated
                testExternalUrl = "pandora:/createStation?artist=\(pandoraArtist.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
            })
            Button("Cancel", action: {})
        }
        .sheet(isPresented: $showEmail) {
            func save(address: String, subject: String, emailBody: String) {
                showEmail = false
                activeSheet = .AppLinkCreated
                testExternalUrl = "mailto:\(address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&body=\(emailBody.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
                DispatchQueue.main.async {
                    showIntegrationIdeas = true
                }
//                print("Save")
            }
            func cancel() {
                showEmail = false
//                print("Cancel")
            }
            return Email(save: save, cancel: cancel)
        }
        .actionSheet(isPresented: $showIntegrationIdeas) {
            switch(activeSheet) {
            case .Main: return ActionSheet(
                title: Text(LocalizedStringKey("Integrations")),
                message: Text(LocalizedStringKey("Available Integrations")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Directions")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showDirections = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Email")), action: {
                        showEmail = true
                    }),
                    .default(Text(LocalizedStringKey("Facebook")), action: {
                        activeSheet = .Facebook
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Contacts")), action: {
                        activeSheet = .Contacts
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Facetime")), action: {
                        activeSheet = .Facetime
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("IMDB (Movies)")), action: {
                        activeSheet = .IMDB
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Music Player")), action: {
                        testExternalUrl = "music://"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("MyTalkTools"), action: {
                        activeSheet = .MyTalk
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Pandora")), action: {
                        activeSheet = .Pandora
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Skype")), action: {
                        activeSheet = .Skype
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("SMS")), action: {
                        showSMS = true
                    }),
                    .default(Text(LocalizedStringKey("Telephone")), action: {
                        showTelephone = true
                    }),
                    .default(Text(LocalizedStringKey("Video Player")), action: {
                        testExternalUrl = "videos://"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),

                ]
            )

            case .IMDB: return ActionSheet(
                title: Text(LocalizedStringKey("IMDB")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Show Times")), action: {
                        testExternalUrl = "imdb:///showtimes"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Box Office")), action: {
                        testExternalUrl = "imdb:///boxoffice"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Coming Soon")), action: {
                        testExternalUrl = "imdb:///feature/comingsoon"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Actors Born Today")), action: {
                        testExternalUrl = "imdb:///feature/borntoday"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("TV Show Recaps")), action: {
                        testExternalUrl = "imdb:///feature/tvrecaps"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    })
                ]
            )
            case .Contacts: return ActionSheet(
                title: Text(LocalizedStringKey("Contacts")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("All Contacts")), action: {
                        testExternalUrl = "contacts://"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("One Contact")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showContact = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Selected Contacts")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showContacts = true
                        }
                    })
                ]
            )
            case .Skype: return ActionSheet(
                title: Text(LocalizedStringKey("Skype")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Voice")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSkypePhoneNumber = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Video")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSkypePhoneNumber = true
                        }
                    })
                ]
            )
            case .ChildBoard: return ActionSheet(
                title: Text(LocalizedStringKey("Child Board")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("New")), action: {
                        activeSheet = .NewBoard
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Existing")), action: {
                        //                        showCamera = true
                    }),
                    .default(Text(LocalizedStringKey("From Library")), action: {
                        libraryFilter = .board
                        showLibraries = true
                    }),
                    .default(Text(LocalizedStringKey("From File")), action: {

                    })
                ]
            )
            case .NewBoard: return ActionSheet(
                title: Text(LocalizedStringKey("New Child Board")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Simple Board")), action: {
                        showNewSimpleBoard = true
                    }),
                    .default(Text(LocalizedStringKey("Word Variant Board")), action: {
                        let word = String(editableContent.editedContent.name.split(separator: " ")[0])
                        Task {
                            do {
                                let words = try await WordVariants().findWordVariants(word)
                                editableContent.childBoardId = try Board.createNewBoard(name: word, words: words!, userId: 0).id
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    }),
                    .default(Text(LocalizedStringKey("Coded Word Variants Board")), action: {
                        let word = String(editableContent.editedContent.name.split(separator: " ")[0])
                        Task {
                            do {
                                let words = try await WordVariants().findWordVariantsWithDefinitions(word)
                                editableContent.childBoardId = try Board.createNewBoard(name: word, words: words!, userId: 0, colorKey: colorKey).id
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    }),
                    .default(Text(LocalizedStringKey("Hotspot Board")), action: {

                    })
                ]
            )            case .Video: return ActionSheet(
                title: Text(LocalizedStringKey("Video")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Saved Photo Albums")), action: {
                        mediaTypes = [.movie]
                        showPhotoLibrary = true
                    }),
                    .default(Text(LocalizedStringKey("Video Camera")), action: {
                        showVideoCamera = true
                    }),
                    .default(Text(LocalizedStringKey("From Library")), action: {
                        libraryFilter = .video
                        showLibraries = true
                    }),
                    .default(Text(LocalizedStringKey("From File")), action: {
                        filePickerType = .video
                        filePickerTYpes = [.video]
                        showFilePicker = true
                    })
                ]
            )
            case .Sound: return ActionSheet(
                title: Text(LocalizedStringKey("Sound")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Text-To-Speech")), action: {
                        showPhrase = true
                    }),
                    .default(Text(LocalizedStringKey("Record Sound")), action: {
                        showRecordAudio = true
                    }),
                    .default(Text(LocalizedStringKey("From Library")), action: {
                        libraryFilter = .sound
                        showLibraries = true
                    }),
                    .default(Text(LocalizedStringKey("From File")), action: {
                        filePickerType = .sound
                        filePickerTYpes = [.aiff, .mp3, .wav]
                        showFilePicker = true
                    })
                ]
            )
            case .Image: return ActionSheet(
                title: Text(LocalizedStringKey("Image")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Saved Photo Albums")), action: {
                        mediaTypes = [.image]
                        showPhotoLibrary = true
                    }),
                    .default(Text(LocalizedStringKey("Camera")), action: {
                        showCamera = true
                    }),
                    .default(Text(LocalizedStringKey("Web Image Search")), action: {
                        showWebImageSearch = true
                    }),
                    .default(Text(LocalizedStringKey("Web Page")), action: {
                        showWebBrowser = true
                    }),
                    .default(Text(LocalizedStringKey("From Library")), action: {
                        libraryFilter = .image
                        showLibraries = true
                    }),
                    .default(Text(LocalizedStringKey("From File")), action: {
                        filePickerType = .image
                        filePickerTYpes = [.jpeg, .png, .bmp]
                        showFilePicker = true
                    }),
                    .default(Text(LocalizedStringKey("From Contacts")), action: {
                        showContactPicker = true
                    })
                ]
            )
            case .Facebook: return ActionSheet(
                title: Text(LocalizedStringKey("Facebook")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Profile")), action: {
                        testExternalUrl = "fb://profile"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Friends")), action: {
                        testExternalUrl = "fb://friends"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Friend Requests")), action: {
                        testExternalUrl = "fb://requests"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Events")), action: {
                        testExternalUrl = "fb://events"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("News Feed")), action: {
                        testExternalUrl = "fb://feed"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Albums")), action: {
                        testExternalUrl = "fb://albums"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    })
                ]
            )
            case .Facetime: return ActionSheet(
                title: Text(LocalizedStringKey("Facetime")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Apple ID")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAppleID = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Email")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showFacetimeEmail = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Phone Number")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPhoneNumber = true
                        }
                    })
                ]
            )
            case .Pandora: return ActionSheet(
                title: Text(LocalizedStringKey("Pandora")),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Artist")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPandoraArtist = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Song")), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPandoraSong = true
                        }
                    })
                ]
            )
            case .MyTalk: return ActionSheet(
                title: Text("MyTalkTools"),
                message: Text(LocalizedStringKey("Available Options")),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Go To Home")), action: {
                        testExternalUrl = "mtt:/home"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Go Back")), action: {
                        testExternalUrl = "mtt:/back"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Show Phrase Bar")), action: {
                        testExternalUrl = "mtt:/phraseBarOn"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Phrase Bar Backspace")), action: {
                        testExternalUrl = "mtt:/phraseBarBackspace"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Phrase Bar Clear")), action: {
                        testExternalUrl = "mtt:/phraseBarClear"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Phrase Bar Play")), action: {
                        testExternalUrl = "mtt:/play"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Phrase Bar Keypress")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Phrase Bar Make Word")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Hide Phrase Bar")), action: {
                        testExternalUrl = "mtt:/phraseBarOff"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Toggle Phrase Bar")), action: {
                        testExternalUrl = "mtt:/phraseBarToggle"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("View Phrase Bar History")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Display Keyboard")), action: {
                        testExternalUrl = "mtt:/type"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("Voice a Phrase")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Exit MyTalk")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Print")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("View Schedules")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("View Locations")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("View Most Used Cells")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("View Most Recent Cells")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("View Wizard")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Increase Volume")), action: { print("Music Player") }),
                    .default(Text(LocalizedStringKey("Decrease Volume")), action: { print("Music Player") })
                ]
            )
            case .AppLinkCreated: return ActionSheet(
                title: Text(LocalizedStringKey("App Link Created")),
                message: Text(testExternalUrl),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text(LocalizedStringKey("Test App Link")), action: {
                        activeSheet = .AppLinkCreated
                        if let url = URL(string: testExternalUrl) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text(LocalizedStringKey("OK")), action: {
                        editableContent.externalUrl = testExternalUrl
                    })
                ])
            }
        }
        .onAppear {
            self.hasBuffer = boardState.copyBuffer.initialized
            editableContent.copy(content: content.setId(contentId))
        }
    }
}

struct EditCell_Previews: PreviewProvider {
    
    static func cancel() {
        print("Cancel")
    }
    
    static func save(content: Content) {
        print("Save")
    }
    static var previews: some View {
        EditCell(content: Content(), save: save, cancel: cancel)
    }
}
