//
//  UserValidation.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

enum UserValidationResponse: Int {
    case NoSuchUser = 0
    case BadPassword = 1
    case Validated = 2
    case NoSqlMembershipRecord = 3
    case UnknownError = 4
}

struct UserValidation: Decodable {
    var d: Int
    var result: UserValidationResponse {
        get {
            return UserValidationResponse(rawValue: d) ?? .UnknownError
        }
    }
    var errorMessage: String {
        get {
            switch result {
            case .NoSuchUser:
                return "The username is not valid"
            case .BadPassword:
                return "The password is not valid"
            case .Validated:
                return "Success"
            case .NoSqlMembershipRecord:
                return "Could not find your account"
            case .UnknownError:
                return "Unknown error"
            }
        }
    }
}

struct UserValidationInput: Encodable, Decodable {
    var username: String
    var password: String
}
