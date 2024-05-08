//
//  AuthenticatedViewModel.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation

import Foundation
import SwiftUI
import Alamofire
import SwiftJWT
import LocalAuthentication
import CommonCrypto


class AuthenticatedViewService:  ObservableObject{
    
    public let config: ApplicationConfig
    internal let state: ApplicationStateManager
    internal let appauth: AppAuthHandler
    
    private var codeValue: String? = nil
    
    private var profileUpdateViewService: ProfileUpdateViewService?
    
    private var changePasswordViewService: ChangePasswordViewService?
    
    private var linkUpService: LinkUpService?
    
    private let onLoggedOut: (() -> Void)
    
    internal let session: Session
    
    internal let onLoading: () -> Void
    
    internal let offLoading: () -> Void

    @Published var hasThirdIdToken: Bool
    @Published var idToken: String
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var thirdIdToken: String
    @Published var thirdAccessToken: String
    @Published var thirdRefreshToken: String
    @Published var idTokenClaims: IDTokenClaims?
    @Published var acTokenClaims: ACTokenClaims?
    @Published var rfTokenClaims: RFTokenClaims?
    @Published var thirdIdTokenClaims: IDTokenClaims?
    @Published var thirdAcTokenClaims: ACTokenClaims?
    @Published var thirdRfTokenClaims: RFTokenClaims?
    @Published var receivedURL: URL?
    @Published var credentials = Credentials()
    @Published var credentialsInfo = CredentialsInfo()
    
    @Published var biometricError: Bool
    
    @Published var biometricEnabled: Bool
    
    @Published var userModel : UserModel?
    
    @Published var ticketId : String?

    @Published var businessId : String?

    
    init(config: ApplicationConfig,
         state: ApplicationStateManager,
         appauth: AppAuthHandler,
         onLoggedOut: @escaping () -> Void,
         onLoading: @escaping () -> Void,
         offLoading: @escaping () -> Void) {
        self.config = config
        self.state = state
        self.appauth = appauth
        self.onLoggedOut = onLoggedOut
        self.onLoading = onLoading
        self.offLoading = offLoading
        self.hasThirdIdToken = false
        self.idTokenClaims = nil
        self.acTokenClaims = nil
        self.rfTokenClaims = nil
        self.thirdIdTokenClaims = nil
        self.thirdAcTokenClaims = nil
        self.thirdRfTokenClaims = nil
        //self.userModel = nil
        self.idToken = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.thirdIdToken = ""
        self.thirdAccessToken = ""
        self.thirdRefreshToken = ""
        let manager = ServerTrustManager(evaluators: [
            "192.168.101.60": DisabledTrustEvaluator(),
            "192.168.101.63" : DisabledTrustEvaluator(),
            "192.168.101.55" : DisabledTrustEvaluator(),
            "login.police.gov.hk": DisabledTrustEvaluator(),
            "sso.hpf.gov.hk": DisabledTrustEvaluator(),
            "ums.hpf.gov.hk" : DisabledTrustEvaluator(),
            "login-uat.police.gov.hk": DisabledTrustEvaluator()
        ])
        // Creating the session.
        self.session = Session(serverTrustManager: manager)
        //self.receivedURL = self.state.url
        //self.processTokens()
        self.biometricError = false
        self.biometricEnabled = false
    }
    
    func getProfileUpdateViewService() -> ProfileUpdateViewService{
        if self.profileUpdateViewService == nil {
            self.profileUpdateViewService = ProfileUpdateViewService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut, 
                onLoading: self.onLoading,
                offLoading: self.offLoading
            )
        }
        return self.profileUpdateViewService!
    }
    
    func getChangePasswordViewService() -> ChangePasswordViewService{
        if self.changePasswordViewService == nil {
            self.changePasswordViewService = ChangePasswordViewService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut,
                onLoading: self.onLoading,
                offLoading: self.offLoading
            )
        }
        return self.changePasswordViewService!
    }
    
    func getLinkUpService() -> LinkUpService{
        if self.linkUpService == nil {
            self.linkUpService = LinkUpService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut,
                onLoading: self.onLoading,
                offLoading: self.offLoading
            )
        }
        return self.linkUpService!
    }

    
//    func getIsThirdPartyLogin() -> Bool {
//        return self.state.isUsingThirdPartyLogin
//    }
    
//    func printAuthState(){
//        print(self.state.getAuthState)
//    }
    
    struct IDTokenClaims: Claims {
        var exp: TimeInterval
        var iat: TimeInterval
        var auth_time: TimeInterval
        var jti: String
        var iss: String
        var aud: String
        var sub: String
        var typ: String
        var azp: String
        var session_state: String
        var at_hash: String
        var sid: String
        var lastName: String
        var occupation: String
        var gender: String
        var mobileCountryCode: String
        var mobileNumber: String
        var iAMSmartTokenisedId: String
        var identityDocumentType: String
        var areaOfResidence: String
        var identityDocumentCountry: String
        var dateOfBirth: String
        var preferred_username: String
        var firstName: String
        var maxAuthLevel: String
//        var oldSub: String
        var post: String
        var mailingAddress: String
        var chineseName: String
        var identityDocumentValue: String
        var company: String
        var authLevel: String
        var email: String?
        var hkidNumber: String
    }
    
    struct ACTokenClaims : Claims , Decodable {
        var exp: TimeInterval
        var iat: TimeInterval
        //var auth_time: TimeInterval?
        var jti: String
        var iss: String
        var aud: [String]
        var sub: String
        var typ: String
        var azp: String
        var nonce: String?
        var session_state: String
        var acr: String?
        var realm_access: AcRealmAccess
        var resource_access: AcResourceAccess
        var scope: String
        var sid: String
    }

    struct AcRealmAccess : Claims {
        var roles: [String]
    }

    struct AcResourceAccess : Claims {
        var account: AcAccountAccess
    }

    struct AcAccountAccess : Claims {
        var roles: [String]
    }
        
    struct RFTokenClaims: Claims {
        var exp: TimeInterval?
        var iat: TimeInterval
        var jti: String
        var iss: String
        //var aud: [String]
        var sub: String
        var typ: String
        var azp: String
        var nonce: String?
        var session_state: String
        var scope: String
        var sid: String
    }
    
    func calculateLifetime() -> Int {
        let lifetimeInSeconds = acTokenClaims!.exp - acTokenClaims!.iat
        return Int(lifetimeInSeconds)
    }
    
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available and can be evaluated
        let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            // Handle the error, if needed
//            print("Biometric authentication is unavailable. Error: \(error.localizedDescription)")
        }
        
        return isBiometricAvailable
    }

    func getBiometricImage() -> String {
        let context = LAContext()
        var biometricImage = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    biometricImage = "faceid"
                case .touchID:
                    biometricImage = "touchid"
                case .none:
                    biometricImage = "faceid"
                case .opticID:
                    biometricImage = "faceid"
                @unknown default:
                    biometricImage = "faceid"
                }
            } else {
                biometricImage = ""
            }
        }
        
        return biometricImage
    }
    
    func checkBiometricEnabled() {
        if(KeychainStorage.hasCredentials(Account: "info")){
            if(KeychainStorage.decodeSub() == idTokenClaims?.sub){
                biometricEnabled = true
                biometricError = false
                //return true //Refresh token found, valid account
            }
            else{
                biometricEnabled = true
                biometricError = true
                //return false //Refresh token found, but not valid account
            }
        }
        else{
            biometricError = false
            biometricEnabled = false
            //return false //Refresh token not found
        }
    }

    func getUserProfile(completion: @escaping (Bool) -> Void) {
    
        self.processTokens()
        
        let endpoint = "\(self.config.policeIP)/sso-user-api/mobile/users/\(self.idTokenClaims!.sub)"

        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
        ]
        
        print(endpoint)
        
        self.onLoading()
        
        session.request(endpoint, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserModel.self){ response in
                // Handle the response manually
                self.offLoading()
                            
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(false) // Return the default value on error
                    return
                }
                
                switch response.result {
                case .success(let userModel):
                    self.userModel = userModel
                    print(userModel)
                    completion(true)
                case .failure(let _error):
                    self.userModel = nil
                    Logger.info(data: "User Model Not Found")
                    completion(false) // Handle network errors
                }
            }
    }

    func processTokens() {
        
        if self.state.tokenResponse?.idToken != nil {
            
            self.idToken = self.state.tokenResponse!.idToken!
            //print("Print ID TOKen" + self.state.idToken!)
                        
            do {
                let jwt = try JWT<IDTokenClaims>(jwtString: self.idToken)
                self.idTokenClaims = jwt.claims
                print(self.idTokenClaims!)
                
            } catch {
                print(error)
            }
        }
        
        if self.state.tokenResponse?.accessToken != nil {
            
            self.accessToken = self.state.tokenResponse!.accessToken!
            //print("Print Ac token" + self.accessToken)
                        
            do {
                let jwt = try JWT<ACTokenClaims>(jwtString: self.accessToken)
                self.acTokenClaims = jwt.claims
                //print(self.acTokenClaims!.aud)

            } catch {
                print(error)
            }
        }
        
        if self.state.tokenResponse?.refreshToken != nil {
            
            self.refreshToken = self.state.tokenResponse!.refreshToken!
            //print("Print RF token" + self.state.rfToken!)
                        
//            do {
//                let jwt = try JWT<RFTokenClaims>(jwtString: self.refreshToken)
//                self.rfTokenClaims = jwt.claims
//                //print(self.acTokenClaims!.aud)
//
//            } catch {
//                print(error)
//            }
        }
    }

    func enableBiometric(completion: @escaping (Bool) -> Void){
        let context = LAContext()
        var error : NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is for security reasons") { success, authenticationError in
                Task.detached{
                    if success{
                        print("Unlocked")
                        self.onLoading()
                        self.getCodeByCookie(){completed in
                            if completed{
                                Logger.info(data: "get offline token success")
                                self.credentialsInfo.sub = self.idTokenClaims!.sub
                                self.credentials.refreshToken = self.refreshToken
                                do{
                                    try KeychainStorage.saveCredentialsInfo(self.credentialsInfo)
                                    Logger.info(data: "Added credentials info")
//                                    self.biometricEnabled = true
                                    completion(true)
                                }
                                catch{
                                    if let error = error as? KeychainError {
                                        Logger.error(data: error.localizedDescription)
                                    }
                                    completion(false)
                                }
                                do{
                                    try KeychainStorage.saveCredentials(self.credentials)
                                    Logger.info(data: "Added credentials")
                                    self.biometricEnabled = true
                                    completion(true)
                                }
                                catch{
                                    if let error = error as? KeychainError {
                                        Logger.error(data: error.localizedDescription)
                                    }
                                    completion(false)
                                }
                            }
                            else{
                                Logger.error(data: "Enable Failed")
                            }
                            self.offLoading()
                        }
                    }
                    else{
                        print("There was a problem!")
                        completion(false)
                    }
                }
            }
        }
        else {
            print("Phone does not have Biometrics")
            completion(false)
        }
    }
    
    func getCodeByCookie(completion: @escaping (Bool) -> Void) {
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)"
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.offlineScope)"
        ]

        // if let requestURL = url {
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(endpoint, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .validate()
            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(false)
                    return
                }
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    print("Redirect URL: \(redirectURL)")
                    if let components = URLComponents(string: redirectURL),
                       let queryItems = components.queryItems {
                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
                            print("Code: \(code)")
                            self.getOfflineTokenBycode(Code: code, isThirdParty: false){completed in
                                if completed{
                                    completion(true)
                                }
                                else{
                                    completion(false)
                                }
                            }
                        }
                    }
                } else {
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                    completion(false)
                }
            }
        
    }
        
    func getOfflineTokenBycode(Code: String, isThirdParty: Bool, completion: @escaping (Bool) -> Void){
        Task{
            do{
                self.onLoading()
                
                let metadata = try await self.appauth.fetchMetadata()
                
                let redirectUrl = try self.config.getRedirectUri()
                
                let clientSecret = self.config.clientSecret
                
                let tokenResponse = try await self.appauth.getTokensByCode(code: Code, metadata: metadata, clientID: self.config.clientID, codeVerifier: nil, redirectUrl: redirectUrl, scope: self.config.offlineScope, clientSecret: clientSecret)
                
                await MainActor.run {
                    self.state.metadata = metadata
                    self.refreshToken = tokenResponse.refreshToken!
                    self.offLoading()
                    completion(true)
                }
            }
            catch{
                await MainActor.run {
                    let appError = error as? ApplicationError
                    if appError != nil {
                        //self.error = appError!
                        print(appError as Any)
                    }
                    self.offLoading()
                    completion(false)
                }
            }
        }
    }

    
    func disableBiometric(completion: @escaping (Bool) -> Void){
        let context = LAContext()
        var error : NSError?
        //let credentials = KeychainStorage.getCredentials()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is for security reasons") { success, authenticationError in
                Task.detached{
                    if success{
                        print("Unlocked")
                        do{
                            try KeychainStorage.deleteCredentials()
                            Logger.info(data: "Deleted credentials")
                            self.biometricEnabled = false
                            completion(true)
                        }
                        catch{
                            if let error = error as? KeychainError {
                                Logger.error(data: error.localizedDescription)
                            }
                            completion(false)
                        }
                        //completion(true)
                    }
                    else{
                        print("There was a problem!")
                        completion(false)
                    }
                }
            }
        }
        else {
            print("Phone does not have Biometrics")
            completion(false)
        }
    }
    
    func requestDigitalSigning() {
        
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/iamsmart/request-signing"
        
        let parameters = """
        {
            "redirect_uri": "https://login-uat.police.gov.hk/sso-common-api/iamsmart/signing-callback",
            "hashCode": "965e638fda4c70f667efc2d68c40c6111e5965bfc82356d",
            "department":"Hong Kong Police Force Test",
            "serviceName":"DSL-Service",
            "documentName":"DSL001",
            "HKICHash":"irOmWS6GGd6cZN1LOSdlcgsEu3EjneLOdYmIFo/2VVQ=",
            "source":"App_Link"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.accessToken)"
        ]
        
        self.onLoading()
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }
        
        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
        //.validate(statusCode: 200..<300)
            .response{ response in
                // Handle the response manually
                self.offLoading()
                
                do {
                    if let jsonData = response.data,
                       let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let businessId = json["businessID"] as? String,
                       let ticketId = json["ticketID"] as? String
                    {
                        //                            print("Otpkey: \(otpKey)")
                        //                            print("Prefix: \(prefix)")
                        self.businessId = businessId
                        self.ticketId = ticketId
                        
                    } else {
                        print("Invalid response format or missing required fields")
                    }
                } catch {
                    print("Failed to parse response JSON: \(error)")
                }
            }
    }
    
    func requestPdfDigitalSigning() {
        
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/iamsmart/request-pdf-signing"
        
        let parameters = """
        {
            "redirect_uri": "https://login-uat.police.gov.hk/sso-common-api/iamsmart/pdf-signing-callback",
            "docDigest": "965e638fda4c70f667efc2d68c40c6111e5965bfc82356d",
            "department":"Hong Kong Police Force Test",
            "serviceName":"DSL-Service",
            "documentName":"DSL001",
            "HKICHash":"irOmWS6GGd6cZN1LOSdlcgsEu3EjneLOdYmIFo/2VVQ=",
            "source":"App_Link"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.accessToken)"
        ]
        
        self.onLoading()
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }
        
        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
        //.validate(statusCode: 200..<300)
            .response{ response in
                // Handle the response manually
                self.offLoading()
                
                do {
                    if let jsonData = response.data,
                       let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let businessId = json["businessID"] as? String,
                       let ticketId = json["ticketID"] as? String
                    {
                        //                            print("Otpkey: \(otpKey)")
                        //                            print("Prefix: \(prefix)")
                        self.businessId = businessId
                        self.ticketId = ticketId
                        
                    } else {
                        print("Invalid response format or missing required fields")
                    }
                } catch {
                    print("Failed to parse response JSON: \(error)")
                }
            }
    }
    
    func requestReAuthentication() {
        
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/iamsmart/request-re-authentication"
        
        let parameters = """
        {
            "redirect_uri": "https://login-uat.police.gov.hk/sso-common-api/iamsmart/re-authentication-callback",
            "source":"App_Link"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.accessToken)"
        ]
        
        self.onLoading()
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }
        
        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
        //.validate(statusCode: 200..<300)
            .response{ response in
                // Handle the response manually
                self.offLoading()
                
                do {
                    if let jsonData = response.data,
                       let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let businessId = json["businessID"] as? String,
                       let ticketId = json["ticketID"] as? String
                    {
                        //                            print("Otpkey: \(otpKey)")
                        //                            print("Prefix: \(prefix)")
                        self.businessId = businessId
                        self.ticketId = ticketId
                        
                    } else {
                        print("Invalid response format or missing required fields")
                    }
                } catch {
                    print("Failed to parse response JSON: \(error)")
                }
            }
    }

    func deleteAccount(completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users/\(self.idTokenClaims!.sub)"
//        
//        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users"
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
        ]
        
        self.onLoading()
        
        session.request(endpoint, method: .delete, encoding: URLEncoding.httpBody, headers: headers)
            //.validate(statusCode: 200..<300)
            .response{ response in
                // Handle the response manually
                self.offLoading()
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    return
                }
                print(responseStatusCode)
                completion(responseStatusCode)
            }
        //self.offLoading()
    }
    
//    func refreshBiometric(){
//        self.credentials.refreshToken = self.refreshToken
//        if KeychainStorage.saveCredentials(self.credentials){
//            print("Refresh biometric success!")
//        }
//    }

    func startLogout(){
        
        self.onLoading()
        
        let logoutEndpoint = "\(self.config.endSessionEndpoint)"
         
        let postLogoutRedirectURI = self.config.postLogoutRedirectUri // need modify
        
        let parameters: [String: String] = [
            "id_token_hint": self.idToken
//            "post_logout_redirect_uri": postLogoutRedirectURI
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)

        session.request(logoutEndpoint, method: .get, parameters: parameters, encoding: URLEncoding.default)
//            .redirect(using: redirector)
            .response { response in
                self.offLoading()
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200:
                        print("Logout OK")
                    default:
                        print("Error with status code: \(statusCode)")
                    }
                } else {
                    print("Error: no valid HTTP response received.")
                }
            }
        
        self.idTokenClaims = nil
        self.acTokenClaims = nil
        self.rfTokenClaims = nil
        self.idToken = ""
        self.accessToken = ""
        self.refreshToken = ""
        self.state.clearTokenAndCode()
        
//        print(self.state.getAuthState.isAuthorized)
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        onLoggedOut()
    }
}
