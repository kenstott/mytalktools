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
    @AppStorage("BoardName") var storedBoardName = ""
    @AppStorage("CachedBoardNames") var cachedBoardNames: String = "[]"
    @State var username = ""
    @State var password = ""
    @State var boardName = ""
    @State var showLoginError: Bool = false
    @State var loggingIn: Bool = false
    @State var isProfessional = false
    @State var showBoardName = false
    
    
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
                                print(selectedItem)
                                boardName = selectedItem
                            })) {
                                Text(boardName != "" ? boardName : storedBoardName).tag(boardName != "" ? boardName : storedBoardName)
                                ForEach(getBoardNames(), id: \.self) {
                                    Text($0)
                                }
                            }
                        }
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
                            Button {
                                showLoginError = false
                                loggingIn = true
                                Task {
                                    do {
                                        let result = try await isValidUser.execute(params: UserValidationInput(username: username, password: password))
                                        print(result!.d)
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
                                        print(error)
                                    }
                                }
                            } label: {
                                if loggingIn {
                                    ProgressView()
                                } else {
                                    Text(LocalizedStringKey("Login"))
                                }
                            }
                            .alert(isPresented: $isProfessional, content: {
                                Alert(title: Text("Professional Account"),
                                      message: Text("Select a board name from Login"),
                                      dismissButton: Alert.Button.default(Text("OK"),
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
