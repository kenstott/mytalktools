//
//  Author.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import SwiftUI

struct Author: View {
    
    let fileManager = FileManager.default
    var isValidUser = Network<UserValidation, UserValidationInput>(service: "IsValidUser")
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var globalState: BoardState
    @EnvironmentObject var media: Media
    @AppStorage("UserHints") var userHints = true
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("PASSWORD") var storedPassword = ""
    @AppStorage("RememberMe") var rememberMe = true
    @State var username = ""
    @State var password = ""
    @State var showLoginError = false
    
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("User Name", text: $username).autocorrectionDisabled().autocapitalization(.none)
                    SecureField("Password", text: $password).autocorrectionDisabled().autocapitalization(.none)
                    Toggle(isOn: $rememberMe) {
                        Text("Remember Me")
                    }
                    Button {
                        // Handle for got password action.
                    } label: {
                        Text("Forgot password")
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 16)
                
                
                Section {
                    Button {
                        // Handle for forgot password action.
                    } label: {
                        Text("Create new user name")
                    }
                    Button {
                        // Handle for About action.
                    }
                label: {
                    NavigationLink(destination: About()) {
                        Text("About")
                    }
                }
                    Button {
                        // Handle for got password action.
                    } label: {
                        Text("Tell a friend")
                    }
                    Button {
                        // Handle for got password action.
                    } label: {
                        Text("Rate this app")
                    }
                    Button {
                        // Handle for got password action.
                    } label: {
                        Text("Restore purchases at no cost")
                    }
                }
                .alert("Login Error", isPresented: $showLoginError) {} message: {
                    Text(isValidUser.result?.errorMessage ?? "Unknown error")
                }
            }.navigationBarTitle("Login")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button( LocalizedStringKey("Login")) {
                            showLoginError = false
                            Task {
                                let result = try await isValidUser.execute(params: UserValidationInput(username: username, password: password))
                                print(result!.d)
                                if (result!.result == .Validated) {
                                    storedUsername = username
                                    storedPassword = password
                                    self.globalState.authorMode.toggle()
                                    await globalState.setUserDb(username: storedUsername, media: media)
                                    dismiss()
                                } else {
                                    showLoginError = true
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    if (rememberMe) {
                        username = storedUsername
                        password = storedPassword
                    }
                }
        }
    }
}


struct Author_Previews: PreviewProvider {
    static var previews: some View {
        Author().environmentObject(BoardState())
    }
}
