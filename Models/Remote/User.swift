//
//  User.swift
//  test
//
//  Created by Kenneth Stott on 1/21/23.
//

import Foundation

struct ProfileVisibility: Decodable, Encodable {
    var VisibilityMode: Int
    var RoleVisibilities: [String]
    var RelationshipVisibilities: [String]
}

struct ProfileProperty: Decodable, Encodable {
    var DataType: Int
    var DefaultValue: String
    var DefaultVisibility: Int
    var Deleted: Bool
    var IsDirty: Bool
    var Length: Int
    var ModuleDefId: Int
    var PortalId: Int
    var PropertyCategory: String
    var PropertyDefinitionId: Int
    var PropertyName: String
    var PropertyValue: String?
    var ReadOnly: Bool
    var Required: Bool
    var ValidationExpression: String
    var ViewOrder: Int
    var Visible: Bool
    var ProfileVisibility: ProfileVisibility
    var Visibility: Int
    var CreatedByUserID: Int
    var CreatedOnDate: String
    var LastModifiedByUserID: Int
    var LastModifiedOnDate: String
}

struct Membership: Decodable, Encodable {
    var Approved: Bool
    var CreatedDate: String
    var IsDeleted: Bool
    var IsOnLine: Bool
    var LastActivityDate: String
    var LastLockoutDate: String
    var LastPasswordChangeDate: String
    var LockedOut: Bool
    var Password: String?
    var PasswordAnswer: String?
    var PassordConfirm: String?
    var PasswordQuestion: String?
    var UpdatePassword: Bool
    var Email: String
    var ObjectHydrated: Bool
    var Username: String
}

struct BaseUtcOffset: Decodable, Encodable {
    var Ticks: Int
    var Days: Int
    var Hours: Int
    var Milliseconds: Int
    var Minutes: Int
    var Seconds: Int
    var TotalDays: Double
    var TotalHours: Double
    var TotalMilliseconds: Double
    var TotalMinutes: Double
    var TotalSeconds: Double
}
struct PreferredTimeZone: Decodable, Encodable {
    var Id: String
    var DisplayName: String
    var StandardName: String
    var DaylightName: String
    var BaseUtcOffset: BaseUtcOffset
    var SupportsDaylightSavingTime: Bool
}
struct Profile: Decodable, Encodable {
    var Cell: String?
    var City: String?
    var Country: String?
    var Fax: String?
    var FirstName: String?
    var FullName: String?
    var IM: String?
    var IsDirty: Bool
    var LastName: String?
    var Photo: String?
    var PhotoURL: String?
    var PhotoURLFile: String?
    var PostalCode: String?
    var PreferredLocale: String?
    var PreferredTimeZone: PreferredTimeZone?
    var ProfileProperties: [ProfileProperty]?
    var Region: String?
    var Street: String?
    var Telephone: String?
    var Title: String?
    var Unit: String?
    var Website: String?
    var TimeZone: Int?
    var Biography: String?
}

struct Relationship: Decodable, Encodable {
    var RelationshipId: Int
    var Name: String
    var Description: String
    var UserId: Int
    var PortalId: Int
    var RelationshipTypeId: Int
    var DefaultResponse: Int
    var IsPortalList: Bool
    var IsHostList: Bool
    var IsUserList: Bool
    var KeyID: Int
    var CreatedByUserID: Int
    var CreatedOnDate: String
    var LastModifiedByUserID: Int
    var LastModifiedOnDate: String
}
struct Role: Decodable, Encodable {
    var UserRoleID: Int
    var UserID: Int
    var FullName: String
    var Email: String
    var EffectiveDate: String
    var ExpiryDate: String
    var IsOwner: Bool
    var IsTrialUsed: Bool
    var Subscribed: Bool
    var IsSystemRole: Bool
    var AutoAssignment: Bool
    var BillingFrequency: String
    var BillingPeriod: Int
    var Description: String
    var IconFile: String
    var IsPublic: Bool
    var PortalID: Int
    var RoleID: Int
    var RoleGroupID: Int
    var RoleName: String
    var RoleType: Int
    var RSVPCode: String
    var SecurityMode: Int
    var ServiceFee: Double
//    var Settings: Any?
    var Status: Int
    var TrialFee: Double
    var TrialFrequency: String
    var TrialPeriod: Int
    var UserCount: Int
    var PhotoURL: String
    var KeyID: Int
    var Cacheability: Int
    var CreatedByUserID: Int
    var CreatedOnDate: String
    var LastModifiedByUserID: Int
    var LastModifiedOnDate: String
}
struct Social: Decodable, Encodable {
    var Friend: String?
    var Follower: String?
    var Following: String?
    var UserRelationships: [String]
    var Relationships: [Relationship]
    var Roles: [Role]
}

struct UserInfoResult: Decodable, Encodable {
    var DisplayName: String
    var Email: String
    var FirstName: String
    var LastName: String
    var IsDeleted: Bool
    var IsSuperUser: Bool
    var LastIPAddress: String
    var Membership: Membership
    var PasswordResetToken: String
    var PasswordResetExpiration: String
    var PortalID: Int
    var Profile: Profile
    var Roles: [String]
    var Social: Social
    var UserID: Int
    var Username: String
    var VanityUrl: String
    var Cacheability: Int
    var FullName: String
    var RefreshRoles: Bool
    var CreatedByUserID: Int
    var CreatedOnDate: String
    var LastModifiedByUserID: Int
    var LastModifiedOnDate: String
}

struct UserInfo: Decodable, Encodable {
    var d: UserInfoResult
}

struct UserInfoInput: Decodable, Encodable {
    var userName: String
}

struct OwnerIdInput: Convertable, Encodable {
    var ownerId: String
}

struct SharedUser: Decodable, Encodable, Hashable {
    static func == (lhs: SharedUser, rhs: SharedUser) -> Bool {
        return lhs.dollarSignId == rhs.dollarSignId &&
        lhs.Create == rhs.Create &&
        lhs.Delete == rhs.Delete &&
        lhs.Read == rhs.Create &&
        lhs.Update == rhs.Delete &&
        lhs.Invitation == rhs.Invitation &&
        lhs.UserNameorInviteEmail == rhs.UserNameorInviteEmail &&
        lhs.UserRightId == rhs.UserRightId &&
        lhs.Version == rhs.Version
    }
    
    init() {
        dollarSignId = "0"
        Create = false
        Delete = false
        Read = false
        Update = false
        Invitation = false
        UserNameorInviteEmail = ""
        UserRightId = 0
        Version = ""
    }
    
    var dollarSignId: String
    var Create: Bool
    var Delete: Bool
    var Read: Bool
    var Update: Bool
    var Invitation: Bool
    var UserNameorInviteEmail: String?
    var UserRightId: Int
    var Version: String
}
struct LibraryRoot: Decodable, Encodable, Identifiable, Hashable {
    static func == (lhs: LibraryRoot, rhs: LibraryRoot) -> Bool {
        return lhs.LibraryId == rhs.LibraryId && lhs.Name == rhs.Name && lhs.OwnerId == rhs.OwnerId && lhs.Version == rhs.Version && lhs.SharedUsers == rhs.SharedUsers
    }
    
    var id: Int? { get {
        return LibraryId
    }}
    var LibraryId: Int
    var Name: String
    var OwnerId: String
    var SharedUsers: [SharedUser]?
    var Version: String
    var read, write, update, delete: Bool?
}

class User: Identifiable, ObservableObject {
    
    static var isValidUser = Network<UserValidation, UserValidationInput>(service: "IsValidUser")
    var getUserInfo = Network<UserInfo, UserInfoInput>(service: "GetUserByUserName")
    var getLibrariesPost = GetPost<Array<LibraryRoot>, OwnerIdInput>(service: "GetLibraryTitles")
    
    @Published var id: Int = 0
    @Published var email: String? = nil
    @Published var username: String = ""
    @Published var libraries: Array<LibraryRoot>? =  nil
    @Published var myLibraries: Array<LibraryRoot>? =  nil
    @Published var sharedLibraries: Array<LibraryRoot>? =  nil
    @Published var profile: UserInfoResult? = nil
    
    static func isValidUser(username: String, password: String) async -> Bool {
        do {
            let result = try await isValidUser.execute(params: UserValidationInput(username: username, password: password))
            return result?.d == 2
        } catch {
            /* ignore */
        }
        return false
    }
    
    func getProfile(_ username: String) async -> UserInfoResult? {
        var result: UserInfoResult?
        do {
            if username == self.username && self.profile != nil {
                return self.profile;
            }
            let userInfo = try await getUserInfo.execute(params: UserInfoInput(userName: username ))
            result = userInfo?.d
            DispatchQueue.main.async {
                self.profile = userInfo?.d
                self.email = userInfo?.d.Email ?? ""
                self.username = userInfo?.d.Username ?? ""
                self.getLibraries()
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return result
    }
    
    public func getLibraries() {
        Task {
            do {
                let result = try await getLibrariesPost.execute(params: OwnerIdInput(ownerId: username ))
                DispatchQueue.main.async {
                    self.libraries = (result ?? []).sorted { $0.Name > $1.Name };
                    self.sharedLibraries = self.libraries?.filter { $0.OwnerId != self.username }.sorted { $0.Name > $1.Name }
                    self.myLibraries = self.libraries?.filter { $0.OwnerId == self.username }.sorted { $0.Name > $1.Name }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
