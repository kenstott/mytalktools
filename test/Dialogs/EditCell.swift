//
//  EditCell.swift
//  test
//
//  Created by Kenneth Stott on 4/1/23.
//

import SwiftUI

struct EditCell: View {
    
    @State var content: Content
    @State var contentType: ContentType
    @State var editedContent: Content
    @State var isOpaque: Bool
    @State var image: UIImage
    @State var name: String
    @State var negate: Bool
    @State var positive: Bool
    @State var imageUrl: String
    @State var soundUrl: String
    @State var childBoard: UInt
    @State var childBoardId: UInt
    @State var childBoardLink: UInt
    @State var includeRepeatedCells: Bool
    @State var popupStyleBoard: Bool
    var save: (() -> Void)? = nil
    var cancel:  (() -> Void)? = nil
    
    
    init(content: Content, save: @escaping () -> Void, cancel: @escaping () -> Void) {
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
        self.editedContent = content.copy(id: content.id)
        switch (content.contentType) {
        case .goBack: contentType = .goBack
        case .goHome: contentType = .goHome
        default: contentType = .imageSoundName
        }
        self.editedContent.contentType = contentType
        
    }
    
    var body: some View {
        UITextField.appearance().clearButtonMode = .always
        return NavigationView {
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
                        TextField(text: $name, prompt: Text("Cell Text")) {
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
                                        } label: {
                                            Label(LocalizedStringKey("Rotate"), systemImage: "rotate.right").labelStyle(.iconOnly)
                                        }
                                        Button {
                                            print("Share")
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
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .background(isOpaque ? .white : .clear)
                                        .padding(0)
                                        .border(.gray, width: 1)
                                        .frame(width: 160, height: 120.0)
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
                }
            }
            .navigationBarTitle("Edit Cell")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        save!()
                    } label: {
                        Text("Save")
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .cancel) {
                        cancel!()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }
            Spacer()
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
        .onChange(of: image) {
            newValue in
            print("Image changed")
        }
        .onChange(of: soundUrl) {
            newValue in
            editedContent.soundURL = newValue
            print(newValue)
        }
    }
}

struct EditCell_Previews: PreviewProvider {
    
    static func cancel() {
        print("Cancel")
    }
    
    static func save() {
        print("Save")
    }
    static var previews: some View {
        EditCell(content: Content(), save: save, cancel: cancel)
    }
}
