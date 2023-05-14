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
    let syncHost = "https://www.mytalktools.com/dnn/sync.asmx"
    var service: String
    
    @Published var result: Output?
    
    init(service: String) {
        self.service = service
    }
    
    func getSyncRequest(_ input: Convertable) -> URLRequest? {
        do {
            let encoder = JSONEncoder()
            let httpBody = try encoder.encode(input)
            guard let url = URL(string: "\(syncHost)/\(service)") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")  // the request is JSON
            urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")        // the expected response is also JSON
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = httpBody
            return urlRequest
        } catch let error {
            print(error)
            return nil
        }
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
    
    func syncService(params: Input) async throws -> Output? {
        let urlRequest = getSyncRequest(params)
        let (data, responseRaw) = try await URLSession.shared.data(for: urlRequest!)
        let response = responseRaw as? HTTPURLResponse
        if response!.statusCode == 200 {
            var stringResult = String(data: data, encoding: .utf8) ?? "[]"
            stringResult = stringResult
                .replacingOccurrences(of: "fake(", with: "")
                .replacingOccurrences(of: "},]", with: "}]")
                .replacingOccurrences(of: "}])", with: "}]")
                .replacingOccurrences(of: "$id", with: "dollarSignId")
                .replacingOccurrences(of: "\"Sort3\":0})", with: "\"Sort3\":0}")
//            print(stringResult)
            result = try JSONDecoder().decode(Output.self, from: Data(stringResult.utf8))
            return result
        } else {
            print("Error: \(response!.statusCode)")
            return nil
        }
    }
    
    func execute(params: Input) async throws -> Output? {
        let urlRequest = getUrlRequest(params)
        let (data, responseRaw) = try await URLSession.shared.data(for: urlRequest)
        let response = responseRaw as? HTTPURLResponse
        if response!.statusCode == 200 {
            var stringResult = String(data: data, encoding: .utf8) ?? "[]"
            stringResult = stringResult.replacingOccurrences(of: "fake(", with: "")
                .replacingOccurrences(of: "},]", with: "}]")
                .replacingOccurrences(of: "}])", with: "}]")
                .replacingOccurrences(of: "$id", with: "dollarSignId")
                .replacingOccurrences(of: "\"Sort3\":0})", with: "\"Sort3\":0}")
//            print(stringResult)
            result = try JSONDecoder().decode(Output.self, from: Data(stringResult.utf8))
            return result
        } else {
            print("Error: \(response!.statusCode)")
            return nil
        }
    }
}
