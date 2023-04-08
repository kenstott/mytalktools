//
//  GetPost.swift
//  test
//
//  Created by Kenneth Stott on 3/4/23.
//

import Foundation

//
//  Network.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

class GetPost<Output: Decodable, Input: Convertable>: ObservableObject {
    
    let encoder = JSONEncoder()
    let host = "https://www.mytalktools.com/dnn/get-post.ashx"
    var service: String
    
    @Published var result: Output?
    
    init(service: String) {
        self.service = service
    }
    
    func getUrlRequest(_ input: Convertable) -> URLRequest {
        let inputDictionary = input.convertToDict() ?? [:];
        var queryString = "callback=fake"
        for param in inputDictionary {
            queryString = "\(queryString)&\(param.key)=\(param.value)"
        }
        guard let url = URL(string: "\(host)/\(service)?\(queryString)") else { fatalError("Missing URL") }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")  // the request is JSON
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
    
    func getJsonData(obj: Encodable) -> Data {
        let jsonString = String(data: try! encoder.encode(obj), encoding: .utf8)
        return jsonString!.data(using: .utf8, allowLossyConversion: false)!
    }
    
    func execute(params: Input) async throws -> Output? {
        let urlRequest = getUrlRequest(params)
        let (data, responseRaw) = try await URLSession.shared.data(for: urlRequest)
        let response = responseRaw as? HTTPURLResponse
        if response!.statusCode == 200 {
            var stringResult = String(data: data, encoding: .utf8) ?? "[]"
            stringResult = stringResult.replacing("fake(", with: "")
                .replacing("},]", with: "}]")
                .replacing("}])", with: "}]")
                .replacing("$id", with: "dollarSignId")
                .replacing("\"Sort3\":0})", with: "\"Sort3\":0}")
//            print(stringResult)
            result = try JSONDecoder().decode(Output.self, from: Data(stringResult.utf8))
            return result
        } else {
            print("Error: \(response!.statusCode)")
            return nil
        }
    }
}
