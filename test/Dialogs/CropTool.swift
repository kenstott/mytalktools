//
//  CropTool.swift
//  test
//
//  Created by Kenneth Stott on 5/20/23.
//

import SwiftUI
import BrightroomUI
import BrightroomEngine

struct CropTool: View {
    
    @State var imageUrl: String
    @Binding var outUrl: String
    @Environment(\.dismiss) var dismiss
    
    func getEditingStack() -> EditingStack {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent(imageUrl)
        let imageProvider: ImageProvider?
        do {
            imageProvider = try ImageProvider(fileURL: fileURL!)
        } catch {
            imageProvider = nil
        }
        return EditingStack(imageProvider: imageProvider!)
    }
    var body: some View {
        let editingStack = getEditingStack()
        return NavigationView {
            VStack {
                SwiftUIPhotosCropView(editingStack: editingStack) {
                    do {
                        let image = try! editingStack.makeRenderer().render().uiImage
                        let temp = try TemporaryFile(creatingTempDirectoryForFilename: "crop.png")
                        FileManager.default.createFile(atPath: temp.fileURL.path, contents: image.pngData())
                        outUrl = temp.fileURL.path
//                        print(outUrl)
                        dismiss()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                } onCancel: {
                    dismiss()
                }
            }
            .navigationTitle("Crop Image")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

