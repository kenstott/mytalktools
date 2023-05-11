//
//  Network.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

class Network<Output: Decodable, Input: Encodable>: ObservableObject {
    
    let encoder = JSONEncoder()
    let host = "https://www.mytalktools.com/dnn/sync.asmx"
    var service: String
    
    @Published var result: Output?
    
    init(service: String) {
        self.service = service
    }
    
    func getUrlRequest() -> URLRequest {
        guard let url = URL(string: "\(host)/\(service)") else { fatalError("Missing URL") }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")  // the request is JSON
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        urlRequest.httpMethod = "POST"
        return urlRequest
    }
    
    func getJsonData(obj: Encodable) -> Data {
        let jsonString = String(data: try! encoder.encode(obj), encoding: .utf8)
        return jsonString!.data(using: .utf8, allowLossyConversion: false)!
    }
    
    func execute(params: Input) async throws -> Output? {
        var urlRequest = getUrlRequest()
        urlRequest.httpBody = getJsonData(obj: params)
        let (data, responseRaw) = try await URLSession.shared.data(for: urlRequest)
        let response = responseRaw as? HTTPURLResponse
        if response!.statusCode == 200 {
            print(String(data: data, encoding: .utf8) ?? "Problem with network file download.")
            do {
                result = try JSONDecoder().decode(Output.self, from: data)
            }
            catch {
                print(error)
            }
            return result
        } else {
            print("Error: \(response!.statusCode)")
            print(HTTPURLResponse.localizedString(forStatusCode: response!.statusCode))
            return nil
        }
    }
}
