//
//  Author.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import SwiftUI
import LocalAuthentication

struct Author: View {
    
    let fileManager = FileManager.default
    var isValidUser = Network<UserValidation, UserValidationInput>(service: "IsValidUser")
    var query = Network<Query, QueryInput>(service: "Query")
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var boardState: BoardState
    @EnvironmentObject var media: Media
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: User
    @AppStorage("UserHints") var userHints = true
    @AppStorage("LOGINUSERNAME") var storedUsername = ""
    @AppStorage("PASSWORD") var storedPassword = ""
    @AppStorage("RememberMe") var rememberMe = true
    @AppStorage("TouchID") var faceID = false
    @AppStorage("BoardName") var storedBoardName = ""
    @AppStorage("CachedBoardNames") var cachedBoardNames: String = "[]"
    @State var username = ""
    @State var password = ""
    @State var boardName = ""
    @State var showLoginError: Bool = false
    @State var loggingIn: Bool = false
    @State var isProfessional = false
    @State var showBoardName = false
    @State var isUnlocked = false
    @State var showCreateNewUsername = false
    @State var showCreationSuccess = false
    @State var showCreationError = false
    @State var newAccountResponse = NewAccountResponse(d: 13)
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        login()
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    
    func login() {
        showLoginError = false
        loggingIn = true
        Task {
            do {
                let result = try await isValidUser.execute(params: UserValidationInput(username: username, password: password))
//                print(result!.d)
                if (result!.result == .Validated) {
                    let profile = await userState.getProfile(username)
                    if (((profile?.Roles.contains("Professional"))) ?? false == true ) {
                        let boards = try await query.execute(params: QueryInput(query: professionalBoardNames(userid: username), site: "MyTalkDatabase"))
                        setBoardNames(boards?.dd.map { $0.txt ?? "" } ?? [])
                        if (getBoardNames().contains(boardName)) {
                            isProfessional = false
                            storedUsername = username
                            storedPassword = password
                            storedBoardName = boardName
                            self.boardState.authorMode.toggle()
                            await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                            appState.rootViewId = UUID()
                            loggingIn = false
                            dismiss()
                        }
                        else if (getBoardNames().contains(storedBoardName)) {
                            isProfessional = false
                            storedUsername = username
                            storedPassword = password
                            boardName = storedBoardName
                            self.boardState.authorMode.toggle()
                            await boardState.setUserDb(username: storedUsername, boardID: storedBoardName, media: media)
                            appState.rootViewId = UUID()
                            loggingIn = false
                            dismiss()
                        } else {
                            isProfessional = true
                            storedBoardName = ""
                            loggingIn = false
                        }
                    } else {
                        storedUsername = username
                        storedPassword = password
                        self.boardState.authorMode.toggle()
                        await boardState.setUserDb(username: storedUsername, boardID: nil, media: media)
                        loggingIn = false
                        dismiss()
                    }
                } else {
                    showLoginError = true
                    loggingIn = false
                }
            } catch let error {
                showLoginError = true
                loggingIn = false
                print(error.localizedDescription)
            }
        }
    }
    
    func getBoardNames() -> [String] {
        guard let result = try? JSONDecoder().decode([String].self, from: cachedBoardNames.data(using: .utf8, allowLossyConversion: false)!) else {
            return []
        }
        return result;
    }
    func setBoardNames(_ newValue: [String]) -> Void {
        guard let result = try? JSONEncoder().encode(newValue) else { return }
        cachedBoardNames = String(decoding: result, as: UTF8.self)
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Form {
                    Section {
                        TextField("User Name", text: $username).autocorrectionDisabled().autocapitalization(.none)
                        SecureField("Password", text: $password).autocorrectionDisabled().autocapitalization(.none)
                        if showBoardName || storedBoardName != "" {
                            Picker("Board Name", selection: Binding(get: { boardName != "" ? boardName : storedBoardName }, set: { selectedItem in
//                                print(selectedItem)
                                boardName = selectedItem
                            })) {
                                Text(boardName != "" ? boardName : storedBoardName).tag(boardName != "" ? boardName : storedBoardName)
                                ForEach(getBoardNames(), id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        Toggle(isOn: $rememberMe) {
                            Text(LocalizedStringKey("Remember Me"))
                        }
                        Toggle(isOn: $faceID) {
                            Text(LocalizedStringKey("Use Face ID"))
                        }
                        Button {
                            // Handle for got password action.
                        } label: {
                            Text(LocalizedStringKey("Forgot password"))
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    
                    
                    Section {
                        Button {
                            showCreateNewUsername = true
                        } label: {
                            Text(LocalizedStringKey("Create new user name"))
                        }
                        Button {
                            // Handle for About action.
                        }
                    label: {
                        NavigationLink(destination: About()) {
                            Text(LocalizedStringKey("About"))
                        }
                    }
                        Button {
                            // Handle for got password action.
                        } label: {
                            Text(LocalizedStringKey("Tell a friend"))
                        }
                        Button {
                            // Handle for got password action.
                        } label: {
                            Text(LocalizedStringKey("Rate this app"))
                        }
                        Button {
                            // Handle for got password action.
                        } label: {
                            Text(LocalizedStringKey("Restore purchases at no cost"))
                        }
                    }
                    .alert("Login Error", isPresented: $showLoginError) {} message: {
                        Text(isValidUser.result?.errorMessage ?? NSLocalizedString("Unknown error", comment: ""))
                    }
                    .alert("Account Creation Success", isPresented: $showCreationSuccess) {} message: {
                        Text(LocalizedStringKey("Account was successfully created. Your new username and password have been updated. Press login to use your new account."))
                    }
                    .alert("Account Creation Error", isPresented: $showCreationError) {} message: {
                        Text(newAccountResponse.errorMessage)
                    }
                }.navigationBarTitle(LocalizedStringKey("Login"))
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                login()
                            } label: {
                                if loggingIn {
                                    ProgressView()
                                } else {
                                    Text(LocalizedStringKey("Login"))
                                }
                            }
                            .alert(isPresented: $isProfessional, content: {
                                Alert(title: Text(LocalizedStringKey("Professional Account")),
                                      message: Text(LocalizedStringKey("Select a board name from Login")),
                                      dismissButton: Alert.Button.default(Text(LocalizedStringKey("OK")),
                                                                          action: {
                                    showBoardName = true
                                }))
                            })
                            .disabled(loggingIn)
                        }
                    }
                    .onAppear {
                        if (rememberMe) {
                            username = storedUsername
                            password = storedPassword
                        }
                        if (faceID && username != "" && password != "") {
                            authenticate()
                        }
                    }
            }
            .sheet(isPresented: $showCreateNewUsername) {
                NewAccountDialog() { result,username,password in
                    if result.result == .Success {
                        self.username = username
                        self.password = password
                        showCreationSuccess = true
                    } else {
                        self.newAccountResponse = result
                        showCreationError = true
                    }
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
