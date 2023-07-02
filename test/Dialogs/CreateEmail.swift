//
//  BoardSortOrder.swift
//  test
//
//  Created by Kenneth Stott on 4/29/23.
//

import SwiftUI

struct Email: View {
    
    var save: ((String, String, String) -> Void)? = nil
    var cancel:  (() -> Void)? = nil
    @State var emailAddress = ""
    @State var subject = ""
    @State var emailBody = ""
    @State var isEmailValid = false
    
    init(save: @escaping (String, String, String) -> Void, cancel: @escaping () -> Void) {
        self.save = save
        self.cancel = cancel
    }
    
    func textFieldValidatorEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // short format
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    var body: some View {
        NavigationView {
            HStack {
                Form {
                    Section {
                        TextField("Email Address", text: $emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        if !self.isEmailValid {
                            HStack {
                                Spacer()
                                Text(LocalizedStringKey("Email is not valid")).font(.system(size: 12)).foregroundColor(Color.red)
                                Spacer()
                            }
                        }
                        TextField(LocalizedStringKey("Subject"), text: $subject)
                    } header: {
                        Text(LocalizedStringKey("Header"))
                    }
                    Section {
                        TextEditor(text: $emailBody)
                    } header: {
                        Text(LocalizedStringKey("Message"))
                    }
                }
            }
            .onChange(of: emailAddress) {
                newValue in
                isEmailValid = textFieldValidatorEmail(newValue)
            }
            .navigationBarTitle(LocalizedStringKey("Create Email"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        save!(emailAddress, subject, emailBody)
                    } label: {
                        Text(LocalizedStringKey("Save"))
                    }.disabled(!isEmailValid || subject == "" || emailBody == "")
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


