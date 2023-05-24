import SwiftUI
import Contacts
import Combine

struct EmbeddedContactPicker: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) var dismiss
    @Binding var contact: CNContact
    @State var predicate: NSPredicate?
    @State var selectionPredicate: NSPredicate?
    
    typealias UIViewControllerType = EmbeddedContactPickerViewController
    
    final class Coordinator: NSObject, EmbeddedContactPickerViewControllerDelegate {
        
        var parent: EmbeddedContactPicker
        
        init(_ parent: EmbeddedContactPicker) {
            self.parent = parent
        }
        
        func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact) {
            self.parent.contact = contact
            self.parent.dismiss()
        }
        
        func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController) {
            print("canceled")
            self.parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<EmbeddedContactPicker>) -> EmbeddedContactPicker.UIViewControllerType {
        let result = EmbeddedContactPicker.UIViewControllerType()
        result.setPredicate(predicate)
        result.setSelectionPredicate(selectionPredicate)
        result.delegate = context.coordinator
        return result
    }
    
    func updateUIViewController(_ uiViewController: EmbeddedContactPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<EmbeddedContactPicker>) { }

}
