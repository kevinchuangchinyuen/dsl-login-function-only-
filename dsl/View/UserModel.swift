//
//  UserModel.swift
//  dsl
//
//  Created by chuang chin yuen on 8/2/2024.
//

import Foundation

struct LinkUpModel: Decodable {
    let identifier : String
    let user : LinkUpUserModel
}

struct LinkUpUserModel: Decodable {
    let id: String
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let attributes: UserAttributesModel
}

struct UserModel: Decodable {
    let username: String
    let enabled: Bool?
    let emailVerified: Bool?
    let firstName: String
    let lastName: String
    let email: String?
    let credentials: [UserCredentialModel]?
    let attributes: UserAttributesModel
}

struct UserCredentialModel: Decodable {
    let type: String
    let value: String
    let temporary: Bool
}

struct UserAttributesModel: Decodable {
    let oldSub: [String]?
    let mobileCountryCode: [String]
    let mobileNumber: [String]
    let chineseName: [String]
    let mailingAddress: [String]
    let hkidNumber: [String]
    let dateOfBirth: [String]
    let gender: [String]
    let areaOfResidence: [String]
    let company: [String]
    let post: [String]
    let occupation: [String]
    let identityDocumentCountry: [String]
    let identityDocumentType: [String]
    let identityDocumentValue: [String]
    let iAMSmartTokenisedId: [String]
    let authLevel: [String]
    let maxAuthLevel: [String]
    let lastLogin: [String]?
    let latestLogin: [String]?
    let locale: [String]
}
