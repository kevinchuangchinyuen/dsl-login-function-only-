//
//  ApplicationStateManager.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import AppAuth

class ApplicationStateManager {
    
    private var authState: OIDAuthState
    private var metadataValue: OIDServiceConfiguration? = nil
    
    private var idTokenValue: String? = nil
    
    private var isFirstTimeLogin: Bool = false
    
    private var publicIpAdress: String = ""
    
    private var urlValue: URL? = nil
    
    init() {
        self.authState = OIDAuthState(authorizationResponse: nil, tokenResponse: nil, registrationResponse: nil)
    }
    
    var getAuthState: OIDAuthState{
        get {
            return self.authState
        }
    }

    func saveTokens(tokenResponse: OIDTokenResponse) {
        if (tokenResponse.accessToken != nil) {
            self.authState.update(with: tokenResponse, error: nil)
        }
    }
    
    var metadata: OIDServiceConfiguration? {
        get {
            return self.metadataValue
        }
        set(value) {
            self.metadataValue = value
        }
    }

    var idToken: String?{
        get{
            return self.idTokenValue
        }
        set(value){
            self.idTokenValue = value
        }
    }
    
    var tokenResponse: OIDTokenResponse? {
        get {
            return self.authState.lastTokenResponse
        }
    }
    
    var getSetFirstTimeLogin: Bool{
        get{
            return self.isFirstTimeLogin
        }
        set(value){
            self.isFirstTimeLogin = value
        }
    }
    
    var getSetIpAddress: String{
        get{
            return self.publicIpAdress
        }
        set(value){
            self.publicIpAdress = value
        }
    }

    func clearTokenAndCode(){
        self.idToken = nil
//        self.acToken = nil
//        self.rfToken = nil
//        self.thirdPartyIdToken = nil
//        self.thirdPartyAcToken = nil
//        self.thirdPartyRfToken = nil
//        self.thirdPartyResponseString = nil
//        self.code = nil
//        self.url = nil
//        self.isUsingThirdPartyLogin = false
        self.isFirstTimeLogin = false
        self.authState = OIDAuthState(authorizationResponse: nil, tokenResponse: nil, registrationResponse: nil)
        //print(self.authState.isAuthorized)
    }
    
    var url: URL?{
        get{
            return self.urlValue
        }
        set(value){
            self.urlValue = value
        }
    }
    
}
