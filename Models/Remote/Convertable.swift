//
//  Convertable.swift
//  test
//
//  Created by Kenneth Stott on 3/4/23.
//

import Foundation
/// define protocol convert Struct or Class to Dictionary
protocol Convertable: Codable {

}

extension Convertable {

    /// implement convert Struct or Class to Dictionary
    func convertToDict() -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>

        } catch {
            print(error)
        }

        return dict
    }
}
