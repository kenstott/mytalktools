//
//  ContentView.swift
//  PrivateWeb
//
//  Created by Benoit PASQUIER on 13/06/2021.
//

import Combine
import WebKit
import SwiftUI

struct WebBrowser: View {
    
    @StateObject var model = WebViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userState: User
    @Binding var imageUrl: String
    @Binding var cellText: String
    
    var body: some View {
        let webView = WebView(webView: model.webView)
        return NavigationView {
            ZStack {
                VStack {
                    HStack {
                        HStack {
                            TextField("Type a URL",
                                      text: $model.urlString)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(10)
                            .border(Color.gray)
                            Spacer()
                            Button(action: {
                                model.loadUrl()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            })
                            Button(action: {
                                model.goBack()
                            }, label: {
                                Image(systemName: "arrowshape.turn.up.backward")
                            })
                            .disabled(!model.canGoBack)
                            
                            Button(action: {
                                model.goForward()
                            }, label: {
                                Image(systemName: "arrowshape.turn.up.right")
                            })
                            .disabled(!model.canGoForward)
                            
                        }
                        .background(Color.white)
                    }
                    .padding(10)
                    
                    ZStack {
                        webView
                        if model.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                
            }
            
            .navigationBarTitle("Web Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        do {
                            let image = webView.webView.asImage()
                            let temp = try TemporaryFile(creatingTempDirectoryForFilename: "web-page.png")
                            FileManager.default.createFile(atPath: temp.fileURL.path, contents: image.pngData())
                            imageUrl = temp.fileURL.path
//                            print(imageUrl)
                            dismiss()
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    } label: {
                        Text(LocalizedStringKey("Save"))
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text(LocalizedStringKey("Cancel"))
                    }
                    
                }
            }
        }
    }
}

struct WebBrowser_Previews: PreviewProvider {
    static var previews: some View {
        WebBrowser(imageUrl: .constant(""), cellText: .constant("test"))
    }
}
