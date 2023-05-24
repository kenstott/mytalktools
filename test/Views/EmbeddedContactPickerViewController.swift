import Foundation
import ContactsUI
import Contacts

protocol EmbeddedContactPickerViewControllerDelegate: AnyObject {
    func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController)
    func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact)
}

class EmbeddedContactPickerViewController: UIViewController, CNContactPickerDelegate {
    weak var delegate: EmbeddedContactPickerViewControllerDelegate?
    var predicate: NSPredicate?
    var selectionPredicate: NSPredicate?
    
    func setPredicate(_ predicate: NSPredicate?) {
        self.predicate = predicate
    }
    
    func setSelectionPredicate(_ predicate: NSPredicate?) {
        self.selectionPredicate = predicate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.open(animated: animated)
    }
    
    private func open(animated: Bool) {
        let viewController = CNContactPickerViewController()
        viewController.predicateForEnablingContact = predicate
        viewController.predicateForSelectionOfContact = selectionPredicate
        viewController.delegate = self
        self.present(viewController, animated: false)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewControllerDidCancel(self)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewController(self, didSelect: contact)
        }
    }
    
}
