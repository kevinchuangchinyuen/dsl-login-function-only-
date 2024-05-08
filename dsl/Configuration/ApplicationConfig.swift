//
//  ApplicationConfig.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation


struct ApplicationConfig: Decodable {

    let issuer: String
    let clientID: String
    let redirectUri: String
    let postLogoutRedirectUri: String
    let scope: String
    let offlineScope: String
    let clientSecret : String
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let userInfoEndpoint: String
    let endSessionEndpoint: String
    let umsEndpoint: String
    let policeIP: String
//    let thirdPartyIssuer: String
//    let thirdPartyClientID: String
//    let thirdPartyClientSecret: String
//    let thirdPartyRedirectUri: String
//    let thirdPartyAuthorizationEndpoint: String
//    let thirdPartyTokenEndpoint: String
//    let thirdPartyUserInfoEndpoint: String
//    let thirdPartyEndSessionEndpoint: String
//    let app2ClientID: String
//    let app2ClientSecret: String
//    let app2RedirectUri: String
//    let adminClientId: String
//    let adminClientSecret: String
//    let adminName: String
//    let adminPassword: String
//    let adminIssuer: String
//    let brokerClientUUID: String
//    let brokerRoleReadTokenID: String
    
    
    init() {
        self.issuer = ""
        self.clientID = ""
        self.redirectUri = ""
        self.postLogoutRedirectUri = ""
        self.scope = ""
        self.offlineScope = ""
        self.clientSecret = ""
        self.authorizationEndpoint = ""
        self.tokenEndpoint = ""
        self.userInfoEndpoint = ""
        self.endSessionEndpoint = ""
        self.umsEndpoint = ""
        self.policeIP = ""
//        self.thirdPartyIssuer = ""
//        self.thirdPartyClientID = ""
//        self.thirdPartyClientSecret = ""
//        self.thirdPartyRedirectUri = ""
//        self.thirdPartyAuthorizationEndpoint = ""
//        self.thirdPartyTokenEndpoint = ""
//        self.thirdPartyUserInfoEndpoint = ""
//        self.thirdPartyEndSessionEndpoint = ""
//        self.app2ClientID = ""
//        self.app2ClientSecret = ""
//        self.app2RedirectUri = ""
//        self.adminClientId = ""
//        self.adminClientSecret = ""
//        self.adminName = ""
//        self.adminPassword = ""
//        self.adminIssuer = ""
//        self.brokerClientUUID = ""
//        self.brokerRoleReadTokenID = ""
    }
    
    func getIssuerUri() throws -> URL {
        
        guard let url = URL(string: self.issuer) else {

            throw ApplicationError(title: "Invalid Configuration Error", description: "The issuer URI could not be parsed")
        }
        
        return url
    }

    func getRedirectUri() throws -> URL {
        
        guard let url = URL(string: self.redirectUri) else {

            throw ApplicationError(title: "Invalid Configuration Error", description: "The redirect URI could not be parsed")
        }
        
        return url
    }

    func getPostLogoutRedirectUri() throws -> URL {
        
        guard let url = URL(string: self.postLogoutRedirectUri) else {

            throw ApplicationError(title: "Invalid Configuration Error", description: "The post logout redirect URI could not be parsed")
        }
        
        return url
    }
}


struct ApplicationConfigLoader {

    static func load() throws -> ApplicationConfig {
        
        let configFilePath = Bundle.main.path(forResource: "config", ofType: "json")
        let jsonText = try String(contentsOfFile: configFilePath!)
        let jsonData = jsonText.data(using: .utf8)!
        let decoder = JSONDecoder()

        let data =  try decoder.decode(ApplicationConfig.self, from: jsonData)
        return data
    }
}
