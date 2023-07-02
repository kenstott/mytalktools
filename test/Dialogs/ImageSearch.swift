import SwiftUI

struct ImageSearch: View {
    @State var query: String
    @Binding var imageUrl: String
    @State private var results = [BingImageSearchResult]()
    @State private var monochrome = false
    @State private var photo = false
    @State private var clipart = false
    @State private var portrait = false
    @Environment(\.dismiss) var dismiss
    @State private var searchTimer: Timer?
    @State private var searching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(results, id: \.self) { row in
                        HStack {
                            VStack {
                                AsyncImage(url: URL(string: row.thumbnailUrl)) { image in
                                    image
                                        .resizable()
                                    
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            .frame(width: 50, height: 50)
                            Text(row.name)
                        }
                        .onTapGesture {
                            imageUrl = row.contentUrl
                            dismiss()
                        }
                    }
                }
                .searchable(text: $query)
                .navigationTitle("Web Image Search")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            dismiss()
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
                    ToolbarItemGroup(placement: .bottomBar) {
                        Toggle(isOn: $monochrome) {
                            Text(LocalizedStringKey("Monochrome"))
                        }
                        Toggle(isOn: $photo) {
                            Text(LocalizedStringKey("Photo"))
                        }
                        Toggle(isOn: $clipart) {
                            Text(LocalizedStringKey("Clipart"))
                        }
                        Toggle(isOn: $portrait) {
                            Text(LocalizedStringKey("Portrait"))
                        }
                    }
                }
                if searching {
                    ProgressView()
                }
            }
        }
        .onAppear {
            if query != "" {
                search()
            }
        }
        .onChange(of: query) {
            newQuery in
            search()
        }
        .onChange(of: monochrome) {
            newQuery in
            search()
        }
        .onChange(of: portrait) {
            newQuery in
            search()
        }
        .onChange(of: photo) {
            newPhoto in
            if newPhoto {
                clipart = false
            }
            search()
        }
        .onChange(of: clipart) {
            newClipart in
            if newClipart {
                photo = false
            }
            search()
        }
    }
    
    func search() {
        
        //Invalidate and Reinitialise
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            searching = true
            Task {
                var initQuery = "https://api.cognitive.microsoft.com/bing/v5.0/images/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&count=30&mkt=en-US&safeSearch=Strict&size=Large"
                if monochrome {
                    initQuery += "&color=Monochrome"
                }
                if clipart {
                    initQuery += "&imageType=Clipart"
                }
                if photo {
                    initQuery += "&imageType=Photo"
                }
                if portrait {
                    initQuery += "&imageContent=Portrait"
                }
                guard let url = URL(string: initQuery) else {
                    return
                }
                
                var request = URLRequest(url: url)
                request.addValue("92b176f38a344679b7069dc63944148c", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(BingImageSearchResponse.self, from: data)
                            results = response.value
                            searching = false
                            return
                        } catch let error {
                            print(error)
                            searching = false
                        }
                    }
                    
                    print("Error searching for images")
                    searching = false
                }.resume()
            }
        }
    }
}

struct ImageSearch_Previews: PreviewProvider {
    static var previews: some View {
        ImageSearch(query: "test", imageUrl: .constant(""))
    }
}

struct BingImageSearchResponse: Codable {
    var _type: String
    var value: [BingImageSearchResult]
}

struct BingImageSearchResult: Codable, Hashable {
    var thumbnailUrl: String
    var contentUrl: String
    var name: String
}
