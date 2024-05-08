//
//  iamsmartService.swift
//  dsl
//
//  Created by chuang chin yuen on 26/2/2024.
//

import Foundation
import Alamofire
import SwiftUI
import LocalAuthentication
import SwiftJWT

class IamsmartService: UnauthenticatedViewService{
    
    func genKeycloakBrokerRedirect(){
        
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)?kc_idp_hint=iamsmart"

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
            //,"User-Agent": "Android Applink"
        ]
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)"
        ]

        // if let requestURL = url {
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(endpoint, method: .get, parameters: parameters, headers: headers)
            //.validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    print("Redirect URL: \(redirectURL)")
                    self.genAppLink(endpoint: redirectURL)
                } else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }
    
    func genKeycloakBrokerRedirectBrowser(){
        
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)?kc_idp_hint=iamsmart"

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
            //,"User-Agent": "Android Applink"
        ]
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)"
        ]

        // if let requestURL = url {
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(endpoint, method: .get, parameters: parameters, headers: headers)
            //.validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    print("Redirect URL: \(redirectURL)")
                    self.genAppLinkBroswer(endpoint: redirectURL)
                } else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }

    
    func genAppLink(endpoint: String){
        
        self.onLoading()
        
        let headers: HTTPHeaders = [
            "User-Agent": "Android Applink"
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)
//        
//        let isTestAppInstalled = isAppInstalled(bundleIdentifier: "hk.gov.iamsmart.testapp")
//        
//        var headers: HTTPHeaders = [:]
//        
//        print(isTestAppInstalled)
//        
//        if isTestAppInstalled {
//            headers["User-Agent"] = "Android Applink"
//        }
//
        self.onLoading()
        session.request(endpoint, method: .get, headers: headers)
            //.validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                if (300...399).contains(statusCode), let appLink = response.response?.allHeaderFields["Location"] as? String {
                    print("App Link: \(appLink)")
                    guard let appLinkURL = URL(string: appLink) else {
                        // Handle invalid URL
                        return
                    }
                    UIApplication.shared.open(appLinkURL, options: [:]) { success in
                        if !success {
                            self.genKeycloakBrokerRedirectBrowser()
                        }
                    }
                }
                else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }
    
    func genAppLinkBroswer(endpoint: String){
        
        self.onLoading()
        
        let headers: HTTPHeaders = [
            //"User-Agent": "Android Applink"
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)
        
        self.onLoading()
        session.request(endpoint, method: .get, headers: headers)
            //.validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                if (300...399).contains(statusCode), let appLink = response.response?.allHeaderFields["Location"] as? String {
                    print("App Link: \(appLink)")
                    guard let appLinkURL = URL(string: appLink) else {
                        // Handle invalid URL
                        return
                    }
                    UIApplication.shared.open(appLinkURL)
                }
                else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }

    func sendCodeToAuthEndpointLab(){
        
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)"

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)",
            "auth_code": "0ad186353c424c64897fcc00445c9ba1"
//            "state": "eddd527b6"
        ]

        // if let requestURL = url {
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(endpoint, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    print("Redirect URL: \(redirectURL)")
                    if redirectURL.contains("newUser") {
                        self.state.getSetFirstTimeLogin = true
                    }
                    else{
                        self.state.getSetFirstTimeLogin = false
                    }
                    if let components = URLComponents(string: redirectURL),
                       let queryItems = components.queryItems {
                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
                            print("Code: \(code)")
                            self.getFirstPartyTokenBycode(Code: code, isThirdParty: false)
                        }
                    }
                } else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }
    
    func sendCodeToAuthEndpoint(code: String){
        
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)"

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)",
            "auth_code": "\(code)"
        ]

        // if let requestURL = url {
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(endpoint, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    print("Redirect URL: \(redirectURL)")
                    if redirectURL.contains("newUser") {
                        self.state.getSetFirstTimeLogin = true
                    }
                    else{
                        self.state.getSetFirstTimeLogin = false
                    }
                    if let components = URLComponents(string: redirectURL),
                       let queryItems = components.queryItems {
                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
                            print("Code: \(code)")
                            self.getFirstPartyTokenBycode(Code: code, isThirdParty: false)
                        }
                    }
                } else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
        
    }
    
    func isAppInstalled(bundleIdentifier: String) -> Bool {
        guard let url = URL(string: "\(bundleIdentifier)://") else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
}
