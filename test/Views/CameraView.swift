import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var mediaTypes: [UTType] = [UTType.image]
    @State var cameraCaptureMode: UIImagePickerController.CameraCaptureMode = .photo
    @Binding var selectedURL: String
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        let mTypes = mediaTypes.map { i in i.identifier }
        imagePicker.mediaTypes = mTypes
        imagePicker.delegate = context.coordinator
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        if sourceType == .camera {
            imagePicker.cameraCaptureMode = cameraCaptureMode
        }
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image: UIImage? = info[UIImagePickerController.InfoKey.originalImage] as! UIImage?
            let videoUrl: URL? = info[UIImagePickerController.InfoKey.mediaURL] as! URL?
            if (image != nil) {
                let data = image?.jpegData(compressionQuality: 1.0)
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID()).jpeg")
                try? data?.write(to: tempURL)
                parent.selectedURL = tempURL.path
            } else {
                parent.selectedURL = videoUrl!.path;
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
