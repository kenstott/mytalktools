//
//  NewAccount.swift
//  test
//
//  Created by Kenneth Stott on 7/23/23.
//

import Foundation
import SwiftUI

enum NewAccountValidationResponse: Int {
    case AddUser = 0
    case UsernameAlreadyExists = 1
    case UserAlreadyRegistered = 2
    case DuplicateEmail = 3
    case DuplicateProviderUserKey = 4
    case DuplicateUserName = 5
    case InvalidAnswer = 6
    case InvalidEmail = 7
    case InvalidPassword = 8
    case InvalidProviderUserKey = 9
    case InvalidQuestion = 10
    case InvalidUserName = 11
    case ProviderError = 12
    case Success = 13
    case UnexpectedError = 14
    case UnknownError = 15
}

struct NewAccountResponse: Decodable {
    var d: Int
    var result: NewAccountValidationResponse {
        get {
            return NewAccountValidationResponse(rawValue: d) ?? .UnknownError
        }
    }
    var errorMessage: LocalizedStringKey {
        get {
            switch result {
            case .UserAlreadyRegistered:
                return LocalizedStringKey("That user has already been registered")
            case .DuplicateUserName:
                fallthrough
            case .UsernameAlreadyExists:
                return LocalizedStringKey("The username already exists")
            case .DuplicateEmail:
                return LocalizedStringKey("That email is already associated with an account")
            case .InvalidPassword:
                return LocalizedStringKey("That password does not meet our password rules")
            case .InvalidUserName:
                return LocalizedStringKey("That username does not meet our username rules")
            default:
                return LocalizedStringKey("Unknown error")
            }
        }
    }
}

struct NewAccountInput: Encodable, Decodable {
    var userName: String
    var password: String
    var eMail: String
    var firstName: String
    var lastName: String
    var uuid: String
}
