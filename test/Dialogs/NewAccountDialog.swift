//
//  NewAccount.swift
//  test
//
//  Created by Kenneth Stott on 7/23/23.
//

import SwiftUI

struct NewAccountDialog: View {
    @Environment(\.dismiss) var dismiss
    @State var emailAddress = ""
    @State var emailAddressCheck = ""
    @State var userName = ""
    @State var password = ""
    @State var passwordCheck = ""
    @State var parent = ""
    @State var isEmailValid = true
    @State var isComplete = false
    @State var areEmailsIdentical = true
    @State var arePasswordsIdentical = true
    @State var creatingAccount = false
    @State var sampleBoards = [SampleBoard]()
    @State var selectedSampleBoardId: Int = 0
    
    var callback: ((_ response: NewAccountResponse, _ username: String, _ password: String) -> Void)? = nil
    
    func textFieldValidatorEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // short format
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    init( callback: @escaping (_ response: NewAccountResponse, _ username: String, _ password: String) -> Void) {
        self.callback = callback
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                HStack {
                    Form {
                        Section {
                            HStack {
                                Button("Cancel") {
                                    dismiss()
                                }
                                Spacer()
                                Button("Create Account") {
                                    creatingAccount = true
                                    Task {
                                        var names = parent.split(separator: " ");
                                        let firstName = String(names[0]);
                                        names.remove(at: 0)
                                        let lastName = names.joined(separator: "");
                                        let createNewAccount = Network<NewAccountResponse, NewAccountInput>(service: "CreateNewAccount")
                                        let newAccountInput = NewAccountInput(userName: userName, password: password, eMail: emailAddress, firstName: firstName, lastName: lastName, uuid: "")
                                        guard let response = try await createNewAccount.execute(params: newAccountInput) else {
                                            return;
                                        }
                                        creatingAccount = false
                                        dismiss()
                                        callback?(response, userName, password)
                                    }
                                }.disabled(!areEmailsIdentical || !arePasswordsIdentical || !isEmailValid || !isComplete)
                            }
                        }
                        Section {
                            TextField(LocalizedStringKey("User Name"), text: $userName)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    // do nothing
                                }
                            
                        } header: {
                            Text(LocalizedStringKey("Authoring Login"))
                        }
                        Section {
                            SecureField(LocalizedStringKey("Password"), text: $password).autocapitalization(.none)
                                .autocorrectionDisabled()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField(LocalizedStringKey("Repeat Password"), text: $passwordCheck)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !arePasswordsIdentical {
                                HStack {
                                    Spacer()
                                    Text(LocalizedStringKey("Passwords do not match")).font(.system(size: 12)).foregroundColor(Color.red)
                                    Spacer()
                                }
                            }
                        }
                        Section {
                            TextField(LocalizedStringKey("Parent"), text: $parent)
                                .autocapitalization(.words)
                                .autocorrectionDisabled()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField(LocalizedStringKey("Email Address"), text: $emailAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            if !self.isEmailValid {
                                HStack {
                                    Spacer()
                                    Text(LocalizedStringKey("Email is not valid")).font(.system(size: 12)).foregroundColor(Color.red)
                                    Spacer()
                                }
                            }
                            TextField(LocalizedStringKey("Repeat Email"), text: $emailAddressCheck)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            if !areEmailsIdentical {
                                HStack {
                                    Spacer()
                                    Text(LocalizedStringKey("Email is not the same")).font(.system(size: 12)).foregroundColor(Color.red)
                                    Spacer()
                                }
                            }
                        } header: {
                            Text(LocalizedStringKey("Contact Information"))
                        }
                        Section(header: Text("Initial Content")) {
                            Picker(
                                selection: $selectedSampleBoardId,
                                label: Text("Initial Content")
                            ) {
                                ForEach(sampleBoards, id: \.UserID) { item in
                                    Text(item.DisplayName ?? "")
                                }
                            }
                        }
                    }
                }
                .onChange(of: [emailAddress, password, parent, userName]) {
                    newValue in
                    isEmailValid = textFieldValidatorEmail(emailAddress)
                    isComplete = emailAddress != "" && password != "" && parent != "" && userName != ""
                }.onChange(of: [emailAddress, emailAddressCheck]) {
                    newValue in
                    areEmailsIdentical = !isEmailValid || emailAddress == emailAddressCheck
                }.onChange(of: [password, passwordCheck]) {
                    newValue in
                    arePasswordsIdentical = password == passwordCheck
                }.onAppear {
                    Task {
                        sampleBoards = try await Board.getSampleBoards() ?? []
                    }
                }
                if creatingAccount {
                    ProgressView(LocalizedStringKey("Creating Account"))
                }
            }
        }
    }
}

struct NewAccountDialog_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountDialog() {response,username,password in
            
        }
    }
}
