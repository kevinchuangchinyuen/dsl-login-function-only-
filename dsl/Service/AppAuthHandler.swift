//
//  AppAuthHandler.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import AppAuth

class CustomURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

class AppAuthHandler: NSObject, URLSessionDelegate{
    
    private let config: ApplicationConfig
    
    init(config: ApplicationConfig) {
        self.config = config
        //self.userAgentSession = nil
    }

    func fetchMetadata() async throws -> OIDServiceConfiguration {
        
        //let issuerUri = try self.config.getIssuerUri()
        
        let authorizationEndpoint = URL(string: self.config.authorizationEndpoint)
        
        let tokenEndpoint = URL(string: self.config.tokenEndpoint)
                
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint!, tokenEndpoint: tokenEndpoint!)

        OIDURLSessionProvider.setSession(URLSession(configuration: .default, delegate: CustomURLSessionDelegate(), delegateQueue: nil))
        
        return configuration
//        return try await withCheckedThrowingContinuation { continuation in
//            
//            OIDURLSessionProvider.setSession(URLSession(configuration: .default, delegate: CustomURLSessionDelegate(), delegateQueue: nil))
//
//
//            OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUri) { metadata, error in
//                
//                if metadata != nil {
//                    
//                    Logger.info(data: "Metadata retrieved successfully")
//                    Logger.debug(data: metadata!.description)
//                    continuation.resume(returning: metadata!)
//                    
//                } else {
//                    
//                    let error = self.createAuthorizationError(title: "Metadata Download Error", ex: error)
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
    }
    
//    func fetchthirdPartyMetadata() async throws -> OIDServiceConfiguration {
//        
//        let issuerUri = URL(string: self.config.thirdPartyIssuer)!
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            
//            OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUri) { metadata, error in
//                
//                if metadata != nil {
//                    
//                    Logger.info(data: "Metadata retrieved successfully")
//                    Logger.debug(data: metadata!.description)
//                    continuation.resume(returning: metadata!)
//                    
//                } else {
//                    
//                    let error = self.createAuthorizationError(title: "Metadata Download Error", ex: error)
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }

    func getTokensByCode(
        code: String,
        metadata: OIDServiceConfiguration,
        clientID: String,
        codeVerifier: String?,
        redirectUrl: URL,
        scope: String,
        clientSecret: String?) async throws -> OIDTokenResponse{
        
        try await withCheckedThrowingContinuation { continuation in
            
            //let redirectUri = try self.config.getRedirectUri()
            
            let scopesArray = scope.components(separatedBy: " ")
            
            print(scopesArray)
            
            let extraParams = [String: String]()
            
            let tokenRequest = OIDTokenRequest(
                configuration: metadata,
                grantType: OIDGrantTypeAuthorizationCode,
                authorizationCode: code,
                redirectURL: redirectUrl,
                clientID: clientID,
                clientSecret: clientSecret,
                scopes: scopesArray,
                refreshToken: nil,
                codeVerifier: codeVerifier,
                additionalParameters: extraParams
            )
            
            OIDAuthorizationService.perform(tokenRequest) { tokenResponse, ex in
                
                if tokenResponse != nil {
                    
                    Logger.info(data: "Authorization code grant response received successfully")
                    let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                    let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                    let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                    Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)" )
                    //print(ex!)
                    continuation.resume(returning: tokenResponse!)
                    
                } else {
                    
                    let error = self.createAuthorizationError(title: "Authorization Response Error", ex: ex)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        
    func genRequestWithPKCE(
        metadata: OIDServiceConfiguration,
        clientID: String,
        redirectUri: URL,
        clientSecret: String) throws -> OIDAuthorizationRequest {
        
        // Use acr_values to select a particular authentication method at runtime
        let extraParams = [String: String]()
        // extraParams["acr_values"] = "urn:se:curity:authentication:html-form:Username-Password"
        
        //let scopesArray = self.config.scope.components(separatedBy: " ")
        let request = OIDAuthorizationRequest(
            configuration: metadata,
            clientId: clientID,
            clientSecret: clientSecret,
            scopes: ["openid"],
            redirectURL: redirectUri,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams)
            
        Logger.info(data: request.authorizationRequestURL().absoluteString)
        Logger.info(data: request.codeVerifier!)
        // Create a custom URL scheme for the target app
//        let targetAppURLScheme = "com.ksm.kevin.as1"
//        // Construct the URL with the request URL as a parameter
//        let url = URL(string: "\(targetAppURLScheme)://?requesturl=\(request.authorizationRequestURL())")!
//
//        Logger.info(data: url.absoluteString)

        // Open the URL, which will attempt to launch the target app
//        UIApplication.shared.open(url)
            
        return request
    }

    func refreshAccessToken(
            metadata: OIDServiceConfiguration,
            clientID: String,
            clientSecret: String,
            refreshToken: String) async throws -> OIDTokenResponse? {
    
                
        let request = OIDTokenRequest(
            configuration: metadata,
            grantType: OIDGrantTypeRefreshToken,
            authorizationCode: nil,
            redirectURL: nil,
            clientID: clientID,
            clientSecret: clientSecret,
            scope: self.config.offlineScope,
            refreshToken: refreshToken,
            codeVerifier: nil,
            additionalParameters: nil)
                

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<OIDTokenResponse?, Error>) -> Void in
            
            OIDAuthorizationService.perform(request) { tokenResponse, ex in
                
                if tokenResponse != nil {
                    
                    Logger.info(data: "Refresh token grant response received successfully")
                    let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                    let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                    let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                    Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)")
                    
                    continuation.resume(returning: tokenResponse!)
                    
                } else {
                    
                    if ex != nil && self.isRefreshTokenExpiredErrorCode(ex: ex!) {
                        
                        Logger.info(data: "Refresh token expired and the user must re-authenticate")
                        continuation.resume(returning: nil)

                    } else {
                        
                        let error = self.createAuthorizationError(title: "Refresh Token Error", ex: ex)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    /*
     * We can check for specific error codes to handle the user cancelling the ASWebAuthenticationSession window
     */
    private func isUserCancellationErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDGeneralErrorDomain && error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue
    }
    
    /*
     * We can check for a specific error code when the refresh token expires and the user needs to re-authenticate
     */
    private func isRefreshTokenExpiredErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDOAuthTokenErrorDomain && error.code == OIDErrorCodeOAuth.invalidGrant.rawValue
    }

    /*
     * Process standard OAuth error / error_description fields and also AppAuth error identifiers
     */
    private func createAuthorizationError(title: String, ex: Error?) -> ApplicationError {
        
        var parts = [String]()
        if (ex == nil) {

            parts.append("Unknown Error")

        } else {

            let nsError = ex! as NSError
            
            if nsError.domain.contains("org.openid.appauth") {
                parts.append("(\(nsError.domain) / \(String(nsError.code)))")
            }

            if !ex!.localizedDescription.isEmpty {
                parts.append(ex!.localizedDescription)
            }
        }

        let fullDescription = parts.joined(separator: " : ")
        let error = ApplicationError(title: title, description: fullDescription)
        Logger.error(data: "\(error.title) : \(error.description)")
        return error
    }

}
