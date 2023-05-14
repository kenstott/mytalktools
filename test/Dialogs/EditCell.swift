//
//  EditCell.swift
//  test
//
//  Created by Kenneth Stott on 4/1/23.
//

import SwiftUI

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
    }
    
    enum FilePickerType {
        case image
        case sound
        case childBoard
        case video
    }
    
    @EnvironmentObject var userState: User
    @EnvironmentObject var speak: Speak
    @AppStorage("PhraseBarAnimate") var phraseBarAnimate = false
    @AppStorage("TTSVoice2") var ttsVoice = "com.apple.ttsbundle.Samantha-compact"
    @AppStorage("TTSVoiceAlt") var ttsVoiceAlternate = ""
    @AppStorage("SpeechRate") var speechRate: Double = 200
    @AppStorage("VoiceShape") var voiceShape: Double = 100
    
    @State var content: Content
    @State var contentType: ContentType
    @State private var showFilePicker = false
    @State private var filePickerType: FilePickerType = .image
    @State private var filePickerTYpes: [UTType] = [.image]
    @State private var editedContent: Content
    @State private var isOpaque: Bool
    @State private var image: UIImage
    @State private var name: String
    @State private var negate: Bool
    @State private var positive: Bool
    @State private var imageUrl: String
    @State private var soundUrl: String
    @State private var childBoard: UInt
    @State private var childBoardId: UInt
    @State private var childBoardLink: UInt
    @State private var includeRepeatedCells: Bool
    @State private var popupStyleBoard: Bool
    @State private var fontSize: Int
    @State private var foregroundColor: Int
    @State private var backgroundColor: Int
    @State private var cellSize: Int
    @State private var doNotZoomPics: Bool
    @State private var zoom: Bool
    @State private var doNotAddToPhraseBar: Bool
    @State private var hidden: Bool
    @State private var ttsSpeech: String
    @State private var ttsSpeechPrompt: String
    @State private var alternateTTSVoice: Bool
    @State private var alternateTTS: String
    @State private var externalUrl: String
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
    @State private var showRecordAudio = false
    @State private var cameraImage: UIImage = UIImage()
    @State private var showShareSheet = false
    @State public var sharedItems : [Any] = []
    
    var save: ((Content) -> Void)? = nil
    var cancel:  (() -> Void)? = nil
    
    
    //    @Environment(\.dismiss) var dismiss
    
    init(content: Content, save: @escaping (Content) -> Void, cancel: @escaping () -> Void) {
        self.content = content
        self.name = content.name
        self.isOpaque = content.isOpaque
        self.image = content.image
        self.imageUrl = content.imageURL
        self.negate = content.negate
        self.positive = content.positive
        self.save = save
        self.cancel = cancel
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
        switch (content.contentType) {
        case .goBack: contentType = .goBack
        case .goHome: contentType = .goHome
        default: contentType = .imageSoundName
        }
        self.editedContent.contentType = contentType
    }
    
    func getFilename(_ name: String) -> URL? {
        var modString = name.split(separator: ".")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var url = documentsURL?
            .appendingPathComponent(userState.username)
            .appendingPathComponent("Private Library")
            .appendingPathComponent(String(modString[0]))
            .appendingPathExtension(String(modString[1]))
        var increment = 0
        var isDirectory: ObjCBool = false
        while (FileManager.default.fileExists(atPath: url!.path, isDirectory: &isDirectory)) {
            increment += 1
            modString[0] = "\(modString[0])\(increment)"
            url = documentsURL?
                .appendingPathComponent(userState.username)
                .appendingPathComponent("Private Library")
                .appendingPathComponent("\(modString[0])\(increment)")
                .appendingPathExtension(String(modString[1]))
        }
        return url;
    }
    
    func truncateFileURL(_ url: URL) -> String {
        let x = url.path.split(separator: userState.username);
        return "\(userState.username)\(x[1])"
    }
    
    var body: some View {
        UITextField.appearance().clearButtonMode = .always
        return NavigationView {
            HStack {
                Form {
                    Section {
                        Picker(selection: $contentType, label: Text("Cell Type")) {
                            Text("Media").tag(ContentType.imageSoundName)
                            Text("Go Home").tag(ContentType.goHome)
                            Text("Go Back").tag(ContentType.goBack)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    } header: {
                        Text("Cell Type")
                    }
                    if contentType != .goHome && contentType != .goBack {
                        Section {
                            TextField(text: $name, prompt: Text("Cell Text"))
                            {
                                Text("Text")
                            }
                        } header: {
                            Text("Cell Text")
                        }
                        .textFieldStyle(.roundedBorder)
                        Section {
                            VStack {
                                if imageUrl != "" {
                                    Toggle(isOn: $isOpaque) {
                                        Text("Opaque").frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                HStack {
                                    VStack(alignment :.leading) {
                                        Button {
                                            print(imageUrl != "" ? "Swap" : "Add")
                                            showIntegrationIdeas = true
                                            activeSheet = .Image
                                        } label: {
                                            Label(LocalizedStringKey(imageUrl != "" ? "Swap" : "Add"), systemImage: imageUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                        }
                                        if imageUrl != "" {
                                            Button(role: .destructive) {
                                                imageUrl = ""
                                                print("Delete")
                                            } label: {
                                                Label(LocalizedStringKey("Delete"), systemImage: "trash").labelStyle(.iconOnly)
                                            }
                                            Button {
                                                print("Rotate")
                                                image = image.rotate(radians: 1.57079633)!
                                                if let data = image.pngData() {
                                                    var (_, filename, _) = Media.splitFileName(str: imageUrl)
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
                                                    imageUrl = "\(userState.username)/Private Library/\(filename).png"
                                                }
                                            } label: {
                                                Label(LocalizedStringKey("Rotate"), systemImage: "rotate.right").labelStyle(.iconOnly)
                                            }
                                            Button {
                                                print("Share")
                                                var fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                    .first?.appendingPathComponent(imageUrl)
                                                guard let image = UIImage(contentsOfFile: fileURL!.path) else { return }
                                                let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                                                //                                                dismiss()
                                                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                                            } label: {
                                                Label(LocalizedStringKey("Share"), systemImage: "square.and.arrow.up").labelStyle(.iconOnly)
                                            }
                                        }
                                    }.buttonStyle(BorderlessButtonStyle())
                                    Spacer()
                                    if imageUrl != "" {
                                        VStack {
                                            Toggle(isOn: $negate) {
                                                Text("No").frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                            Toggle(isOn: $positive) {
                                                Text("Yes").frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                        }
                                        Spacer()
                                        ZStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .background(isOpaque ? .white : .clear)
                                                .padding(0)
                                                .border(.gray, width: 1)
                                            if negate {
                                                NegateView()
                                            } else if positive {
                                                PositiveView()
                                            }
                                        }.frame(width: 160, height: 160)
                                    }
                                }
                            }
                        } header: {
                            Text("Image")
                        }
                        if soundUrl == "" || !content.isVideo(soundURL: soundUrl) {
                            Section {
                                HStack {
                                    Button {
                                        print(soundUrl != "" ? "Swap" : "Add")
                                        showIntegrationIdeas = true
                                        activeSheet = .Sound
                                    } label: {
                                        Label(LocalizedStringKey(soundUrl != "" ? "Swap" : "Add"), systemImage: soundUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    if soundUrl != "" {
                                        Button(role: .destructive) {
                                            print("Delete")
                                            soundUrl = ""
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
                                Text("Sound")
                            }
                        }
                        if soundUrl == "" || content.isVideo(soundURL: soundUrl) {
                            Section {
                                HStack {
                                    Button {
                                        print(soundUrl != "" ? "Swap" : "Add")
                                        showIntegrationIdeas = true
                                        activeSheet = .Video
                                    } label: {
                                        Label(LocalizedStringKey(soundUrl != "" ? "Swap" : "Add"), systemImage: soundUrl != "" ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                    }
                                    Spacer()
                                    if soundUrl != "" {
                                        Button(role: .destructive) {
                                            print("Delete")
                                            soundUrl = ""
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
                                Text("Video")
                            }
                        }
                        Section {
                            if childBoard > 0 {
                                VStack {
                                    Toggle(isOn: $includeRepeatedCells) {
                                        Text(LocalizedStringKey("Include Repeated Cells"))
                                    }
                                    Toggle(isOn: $popupStyleBoard) {
                                        Text(LocalizedStringKey("Popup Style Board"))
                                    }
                                }
                            }
                            HStack {
                                Button {
                                    print(childBoard > 0 ? "Swap" : "Add")
                                    showIntegrationIdeas = true
                                    activeSheet = .ChildBoard
                                } label: {
                                    Label(LocalizedStringKey(childBoard > 0 ? "Swap" : "Add"), systemImage: childBoard > 0 ? "rectangle.2.swap" : "plus").labelStyle(.iconOnly)
                                }
                                Spacer()
                                if childBoard > 0 {
                                    Button(role: .destructive) {
                                        print("Delete")
                                        
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
                            Text("Child Board")
                        }
                        Section {
                            VStack {
                                HStack {
                                    Text("Font Size")
                                    Stepper(value: $fontSize,
                                            in: 0...50,
                                            step: 1) {
                                        if fontSize != 0 {
                                            Text("\(fontSize) pixels").italic().font(.system(size: 14))
                                        } else {
                                            Text("default size").italic().font(.system(size: 14))
                                        }
                                    }
                                            .padding(5)
                                }
                                
                                Stepper(value: $foregroundColor,
                                        in: 0...16,
                                        step: 1) {
                                    if foregroundColor != Content.ForegroundColorMask.kfDefault.rawValue {
                                        Text("Foreground Color").foregroundColor(Content.convertColor(value: foregroundColor))
                                    } else {
                                        Text("default foreground color").font(.system(size: 14))
                                    }
                                }
                                        .padding(5)
                                Stepper(value: $backgroundColor,
                                        in: 0...16,
                                        step: 1) {
                                    if backgroundColor != Content.ForegroundColorMask.kfDefault.rawValue {
                                        Text("Background Color").background(Content.convertColor(value: backgroundColor))
                                    } else  if backgroundColor != Content.ForegroundColorMask.kfClear.rawValue {
                                        Text("transparent background color").italic().font(.system(size: 14))
                                    } else {
                                        Text("default background color").italic().font(.system(size: 14))
                                    }
                                }
                                        .padding(5)
                                HStack {
                                    Text("Cell Width")
                                    Stepper(value: $cellSize,
                                            in: 1...15,
                                            step: 1) {
                                        
                                        Text("\(cellSize) \(cellSize == 0 ? "column" : "columns")").italic().font(.system(size: 14))
                                        
                                    }
                                            .padding(5)
                                }
                                
                                
                            }
                        } header: {
                            Text("Styles")
                        }
                        Section {
                            VStack {
                                Toggle("Never Zoom", isOn: $doNotZoomPics)
                                Toggle("Always Zoom", isOn: $zoom)
                                Toggle("Do Not Add To Phrase Bar", isOn: $doNotAddToPhraseBar)
                                Toggle("Hide from User", isOn: $hidden)
                            }
                        } header: {
                            Text("Cell Touch")
                        }
                        Section {
                            VStack {
                                HStack {
                                    TextField(LocalizedStringKey("TTS"), text: $ttsSpeech)
                                    Button {
                                        print("Play")
                                    } label: {
                                        Label(LocalizedStringKey("Play"), systemImage: "play").labelStyle(.iconOnly)
                                    }
                                }
                                HStack {
                                    TextField(LocalizedStringKey("Prompt"), text: $ttsSpeechPrompt)
                                    Button {
                                        print("Play")
                                    } label: {
                                        Label(LocalizedStringKey("Play"), systemImage: "play").labelStyle(.iconOnly)
                                    }
                                }
                                Toggle(LocalizedStringKey("Alternate TTS Voice"), isOn: $alternateTTSVoice)
                            }
                        } header: {
                            Text("Text-to-Speech")
                        }
                        Section {
                            HStack {
                                TextField(LocalizedStringKey("Tap + for ideas"), text: $externalUrl)
                                Button {
                                    print("show ideas")
                                    activeSheet = .Main
                                    showIntegrationIdeas = true
                                } label: {
                                    Label(LocalizedStringKey("Add Integration"), systemImage: "plus").labelStyle(.iconOnly)
                                }
                            }
                            
                        } header: {
                            Text("Integration and Automation")
                        }
                    }
                }
                .navigationBarTitle("Edit Cell")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            save!(editedContent)
                        } label: {
                            Text("Save")
                        }
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            cancel!()
                        } label: {
                            Text("Cancel")
                        }
                        
                    }
                }
                Spacer()
            }
            .onChange(of: cameraImage) {
                newValue in
                image = newValue
                let regex : NSRegularExpression = try! NSRegularExpression(pattern:"[^A-Za-z0-9]", options: .caseInsensitive)
                var modString = regex.stringByReplacingMatches(in: name, options: .reportProgress, range: NSMakeRange(0, name.count), withTemplate: "_")
                if modString.count == 0 {
                    modString = "temp"
                }
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                var url = documentsURL?
                    .appendingPathComponent(userState.username)
                    .appendingPathComponent("Private Library")
                    .appendingPathComponent(modString)
                    .appendingPathExtension("png")
                var increment = 1
                var isDirectory: ObjCBool = false
                while (FileManager.default.fileExists(atPath: url!.path, isDirectory: &isDirectory)) {
                    url = documentsURL?
                        .appendingPathComponent(userState.username)
                        .appendingPathComponent("Private Library")
                        .appendingPathComponent("\(modString)\(increment)")
                        .appendingPathExtension("png")
                    increment += 1
                }
                let scaledImage = ImageUtility.scaleAndRotateImage(image, setWidth: 1000, setHeight: 0, setOrientation: image.imageOrientation)
                let pngImageData = scaledImage!.pngData()
                FileManager.default.createFile(atPath: url!.path, contents: pngImageData)
                imageUrl = "\(userState.username)/Private Library/\(url!.lastPathComponent)"
                print(imageUrl)
            }
            .onChange(of: alternateTTSVoice) {
                newValue in
                editedContent.setAlternateTTSVoice(value: newValue)
            }
            .onChange(of: ttsSpeechPrompt) {
                newValue in
                editedContent.ttsSpeechPrompt = newValue
            }
            .onChange(of: ttsSpeech) {
                newValue in
                editedContent.ttsSpeech = newValue
            }
            .onChange(of: externalUrl) {
                newValue in
                editedContent.externalUrl = newValue
            }
            .onChange(of: positive) {
                newValue in
                editedContent.setPositive(value: newValue)
                if positive {
                    negate = false
                }
                print(newValue)
            }
            .onChange(of: negate) {
                newValue in
                editedContent.setNegate(value: newValue)
                if negate {
                    positive = false
                }
                print(newValue)
            }
            .onChange(of: isOpaque) {
                newValue in
                editedContent.setOpaque(value: newValue)
                print(newValue)
            }
            .onChange(of: hidden) {
                newValue in
                editedContent.setHidden(value: newValue)
                print(newValue)
            }
            .onChange(of: doNotAddToPhraseBar) {
                newValue in
                editedContent.doNotAddToPhraseBar = newValue
                print(newValue)
            }
            .onChange(of: zoom) {
                newValue in
                editedContent.zoom = newValue
                print(newValue)
            }
            .onChange(of: doNotZoomPics) {
                newValue in
                editedContent.doNotZoomPics = newValue
                print(newValue)
            }
            .onChange(of: foregroundColor) {
                newValue in
                editedContent.setColor(value: newValue)
                print(newValue)
            }
            .onChange(of: backgroundColor) {
                newValue in
                editedContent.setBackgroundColor(value: newValue)
                print(newValue)
            }
            .onChange(of: fontSize) {
                newValue in
                editedContent.fontSize = newValue
                print(newValue)
            }
            .onChange(of: contentType) {
                newValue in
                editedContent.contentType = newValue
                print(newValue)
            }
            .onChange(of: childBoardId) {
                newValue in
                editedContent.childBoardId = newValue
                print(newValue)
            }
            .onChange(of: childBoardLink) {
                newValue in
                editedContent.childBoardLink = newValue
                print(newValue)
            }
            .onChange(of: name) {
                newValue in
                editedContent.name = newValue
                print(newValue)
            }
            .onChange(of: imageUrl) {
                newValue in
                editedContent.imageURL = newValue
                print(newValue)
            }
            .onChange(of: image) {
                newValue in
                print("Image changed")
            }
            .onChange(of: soundUrl) {
                newValue in
                editedContent.soundURL = newValue
                print(newValue)
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(sourceType: .savedPhotosAlbum, selectedImage: $cameraImage)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $cameraImage)
            }
            .sheet(isPresented: $showRecordAudio) {
                RecordSound(cellText: $name, filename: $soundUrl)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: self.sharedItems)
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: filePickerTYpes) { result in
            switch(filePickerType) {
            case .image:
                do {
                    let tempURL = try result.get()
                    let sourceURL = getFilename(tempURL.lastPathComponent)
                    try FileManager.default.copyItem(at: tempURL, to: sourceURL!)
                    imageUrl = truncateFileURL(sourceURL!)
                    image = UIImage(contentsOfFile: sourceURL!.path)!
                } catch {
                    print(error.localizedDescription)
                }
            case .sound:
                do {
                    let tempURL = try result.get()
                    let sourceURL = getFilename(tempURL.lastPathComponent)
                    try FileManager.default.copyItem(at: tempURL, to: sourceURL!)
                    soundUrl = truncateFileURL(sourceURL!)
                } catch {
                    print(error.localizedDescription)
                }
            default: print("")
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
                let fileURL = Media.generateFileName(str: name, username: userState.username, ext: "wav")
                speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                    soundUrl = "\(userState.username)/Private Library/\(fileURL.lastPathComponent)"
                }
                var alternate: Bool? = alternateTTSVoice
                speak.utter(ttsPhrase, speechRate: speechRate, voiceShape: voiceShape, alternate: &alternate, fileURL: fileURL)
            })
            Button("Test", action: {
                speak.setVoices(ttsVoice, ttsVoiceAlternate: ttsVoiceAlternate) {
                    DispatchQueue.main.async {
                        showPhrase = true
                    }
                }
                var alternate: Bool? = alternateTTSVoice
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
                testExternalUrl = "skype:\(skypePhoneNumber.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
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
                testExternalUrl = "sms:\(smsPhoneNumber.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
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
                testExternalUrl = "tel:\(telephonePhoneNumber.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
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
                print("Save")
            }
            func cancel() {
                showEmail = false
                print("Cancel")
            }
            return Email(save: save, cancel: cancel)
        }
        .actionSheet(isPresented: $showIntegrationIdeas) {
            switch(activeSheet) {
            case .Main: return ActionSheet(
                title: Text("Integrations"),
                message: Text("Available Integrations"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Directions"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showDirections = true
                        }
                    }),
                    .default(Text("Email"), action: {
                        showEmail = true
                    }),
                    .default(Text("Facebook"), action: {
                        activeSheet = .Facebook
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Contacts"), action: {
                        activeSheet = .Contacts
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Facetime"), action: {
                        activeSheet = .Facetime
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("IMDB (Movies)"), action: {
                        activeSheet = .IMDB
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Music Player"), action: {
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
                    .default(Text("Pandora"), action: {
                        activeSheet = .Pandora
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Skype"), action: {
                        activeSheet = .Skype
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("SMS"), action: {
                        showSMS = true
                    }),
                    .default(Text("Telephone"), action: {
                        showTelephone = true
                    }),
                    .default(Text("Video Player"), action: {
                        testExternalUrl = "videos://"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    
                ]
            )
                
            case .IMDB: return ActionSheet(
                title: Text("IMDB"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Show Times"), action: {
                        testExternalUrl = "imdb:///showtimes"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Box Office"), action: {
                        testExternalUrl = "imdb:///boxoffice"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Coming Soon"), action: {
                        testExternalUrl = "imdb:///feature/comingsoon"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Actors Born Today"), action: {
                        testExternalUrl = "imdb:///feature/borntoday"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("TV Show Recaps"), action: {
                        testExternalUrl = "imdb:///feature/tvrecaps"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    })
                ]
            )
            case .Contacts: return ActionSheet(
                title: Text("Contacts"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("All Contacts"), action: {
                        testExternalUrl = "contacts://"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("One Contact"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showContact = true
                        }
                    }),
                    .default(Text("Selected Contacts"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showContacts = true
                        }
                    })
                ]
            )
            case .Skype: return ActionSheet(
                title: Text("Skype"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Voice"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSkypePhoneNumber = true
                        }
                    }),
                    .default(Text("Video"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSkypePhoneNumber = true
                        }
                    })
                ]
            )
            case .ChildBoard: return ActionSheet(
                title: Text("Child Board"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("New"), action: {
                        //                        showPhotoLibrary = true
                    }),
                    .default(Text("Existing"), action: {
                        //                        showCamera = true
                    }),
                    .default(Text("From Library"), action: {
                        
                    }),
                    .default(Text("From File"), action: {
                        
                    })
                ]
            )
            case .Video: return ActionSheet(
                title: Text("Video"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Saved Photo Albums"), action: {
                        //                        showPhotoLibrary = true
                    }),
                    .default(Text("Video Camera"), action: {
                        //                        showCamera = true
                    }),
                    .default(Text("From Library"), action: {
                        
                    }),
                    .default(Text("From File"), action: {
                        
                    })
                ]
            )
            case .Sound: return ActionSheet(
                title: Text("Sound"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Text-To-Speech"), action: {
                        showPhrase = true
                    }),
                    .default(Text("Record Sound"), action: {
                        showRecordAudio = true
                    }),
                    .default(Text("From Library"), action: {
                        
                    }),
                    .default(Text("From File"), action: {
                        filePickerType = .sound
                        filePickerTYpes = [.aiff, .mp3, .wav]
                        showFilePicker = true
                    })
                ]
            )
            case .Image: return ActionSheet(
                title: Text("Image"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Saved Photo Albums"), action: {
                        showPhotoLibrary = true
                    }),
                    .default(Text("Camera"), action: {
                        showCamera = true
                    }),
                    .default(Text("Web Image Search"), action: {
                        
                    }),
                    .default(Text("Web Page"), action: {
                        
                    }),
                    .default(Text("From Library"), action: {
                        
                    }),
                    .default(Text("From File"), action: {
                        filePickerType = .image
                        filePickerTYpes = [.jpeg, .png, .bmp]
                        showFilePicker = true
                    }),
                    .default(Text("From Contacts"), action: {
                        
                    })
                ]
            )
            case .Facebook: return ActionSheet(
                title: Text("Facebook"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Profile"), action: {
                        testExternalUrl = "fb://profile"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Friends"), action: {
                        testExternalUrl = "fb://friends"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Friend Requests"), action: {
                        testExternalUrl = "fb://requests"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Events"), action: {
                        testExternalUrl = "fb://events"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("News Feed"), action: {
                        testExternalUrl = "fb://feed"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Albums"), action: {
                        testExternalUrl = "fb://albums"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    })
                ]
            )
            case .Facetime: return ActionSheet(
                title: Text("Facetime"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Apple ID"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAppleID = true
                        }
                    }),
                    .default(Text("Email"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showFacetimeEmail = true
                        }
                    }),
                    .default(Text("Phone Number"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPhoneNumber = true
                        }
                    })
                ]
            )
            case .Pandora: return ActionSheet(
                title: Text("Pandora"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Artist"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPandoraArtist = true
                        }
                    }),
                    .default(Text("Song"), action: {
                        showIntegrationIdeas = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showPandoraSong = true
                        }
                    })
                ]
            )
            case .MyTalk: return ActionSheet(
                title: Text("MyTalkTools"),
                message: Text("Available Options"),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Go To Home"), action: {
                        testExternalUrl = "mtt:/home"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Go Back"), action: {
                        testExternalUrl = "mtt:/back"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Show Phrase Bar"), action: {
                        testExternalUrl = "mtt:/phraseBarOn"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Phrase Bar Backspace"), action: {
                        testExternalUrl = "mtt:/phraseBarBackspace"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Phrase Bar Clear"), action: {
                        testExternalUrl = "mtt:/phraseBarClear"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Phrase Bar Play"), action: {
                        testExternalUrl = "mtt:/play"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Phrase Bar Keypress"), action: { print("Music Player") }),
                    .default(Text("Phrase Bar Make Word"), action: { print("Music Player") }),
                    .default(Text("Hide Phrase Bar"), action: {
                        testExternalUrl = "mtt:/phraseBarOff"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Toggle Phrase Bar"), action: {
                        testExternalUrl = "mtt:/phraseBarToggle"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("View Phrase Bar History"), action: { print("Music Player") }),
                    .default(Text("Display Keyboard"), action: {
                        testExternalUrl = "mtt:/type"
                        activeSheet = .AppLinkCreated
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showIntegrationIdeas = true
                        }
                    }),
                    .default(Text("Voice a Phrase"), action: { print("Music Player") }),
                    .default(Text("Exit MyTalk"), action: { print("Music Player") }),
                    .default(Text("Print"), action: { print("Music Player") }),
                    .default(Text("View Schedules"), action: { print("Music Player") }),
                    .default(Text("View Locations"), action: { print("Music Player") }),
                    .default(Text("View Most Used Cells"), action: { print("Music Player") }),
                    .default(Text("View Most Recent Cells"), action: { print("Music Player") }),
                    .default(Text("View Wizard"), action: { print("Music Player") }),
                    .default(Text("Increase Volume"), action: { print("Music Player") }),
                    .default(Text("Decrease Volume"), action: { print("Music Player") })
                ]
            )
            case .AppLinkCreated: return ActionSheet(
                title: Text("App Link Created"),
                message: Text(testExternalUrl),
                buttons: [
                    .cancel { print(self.showIntegrationIdeas) },
                    .default(Text("Test App Link"), action: {
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
                    .default(Text("OK"), action: {
                        externalUrl = testExternalUrl
                    })
                ])
            }
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
