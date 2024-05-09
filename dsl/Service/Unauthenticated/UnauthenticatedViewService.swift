//
//  UnauthenticatedViewModel.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import Alamofire
import SwiftUI
import LocalAuthentication
import SwiftJWT

class UnauthenticatedViewService: NSObject , ObservableObject {
    
    internal let config: ApplicationConfig
    internal let state: ApplicationStateManager
    private let appauth: AppAuthHandler
        
    private var iamsmartService: IamsmartService?
 
    @Published var someProperty: String = ""

    @Published var receivedURL: URL?
    
    @Published var tokenResponse: TokenResponse?
        
    @Published var app2IsRequesting: Int
    
    @Published var isOTP = false

//    private let onLoggedIn: () -> Void
//    
    private let onFirstTimeLogin: () -> Void
    
    internal let onLoading: () -> Void
    
    internal let offLoading: () -> Void
    
    internal let session: Session
    
    @Published var otpKey: String
    
    @Published var type: String
    
    @Published var prefix: String
    
    @Published var mobileNumber: String
    
    init(config: ApplicationConfig,
         state: ApplicationStateManager,
         appauth: AppAuthHandler,
         onLoading: @escaping () -> Void,
         offLoading: @escaping () -> Void,
         //onLoggedIn: @escaping () -> Void,
         onFirstTimeLogin: @escaping () -> Void){
        self.config = config
        self.appauth = appauth
        self.receivedURL = nil
        self.tokenResponse = nil
        self.app2IsRequesting = 0
        //self.onLoggedIn = onLoggedIn
        self.onFirstTimeLogin = onFirstTimeLogin
        self.onLoading = onLoading
        self.offLoading = offLoading
        self.state = state
        //self.error = nil
        let manager = ServerTrustManager(evaluators: [
            "192.168.101.60": DisabledTrustEvaluator(),
            "192.168.101.63" : DisabledTrustEvaluator(),
            "192.168.101.55" : DisabledTrustEvaluator(),
            "login.police.gov.hk": DisabledTrustEvaluator(),
            "sso.hpf.gov.hk": DisabledTrustEvaluator(),
            "ums.hpf.gov.hk": DisabledTrustEvaluator(),
            "login-uat.police.gov.hk": DisabledTrustEvaluator()
        ])
        // Creating the session.
        self.session = Session(serverTrustManager: manager)
        self.otpKey = ""
        self.type = ""
        self.prefix = ""
        self.mobileNumber = ""
        //self.session = Session()
    }
    
    
    func getUrl(receiveUrl : URL){
        self.state.url = receiveUrl
    }

//    func getPublicIpAddress() -> String {
//        let url = URL(string: "https://api.ipify.org")
//
//        do {
//            if let url = url {
//                let ipAddress = try String(contentsOf: url)
//                //print("My public IP address is: " + ipAddress)
//                return ipAddress
//            }
//        } catch let error {
//            print(error)
//            return "error"
//        }
//        return "unknown"
//    }
        
    func getIamsmartService() -> IamsmartService {
        
        if self.iamsmartService == nil {
            self.iamsmartService = IamsmartService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoading: self.onLoading,
                offLoading: self.offLoading,
                onFirstTimeLogin: self.onFirstTimeLogin)
        }

        return self.iamsmartService!
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
                    biometricImage = ""
                case .opticID:
                    biometricImage = ""
                @unknown default:
                    biometricImage = ""
                }
            } else {
                biometricImage = ""
            }
        }
        
        return biometricImage
    }
    
    func getBiometricName() -> String {
        let context = LAContext()
        var biometricImage = ""
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .faceID:
                    biometricImage = "Face ID"
                case .touchID:
                    biometricImage = "Touch ID"
                case .none:
                    biometricImage = ""
                case .opticID:
                    biometricImage = ""
                @unknown default:
                    biometricImage = ""
                }
            } else {
                biometricImage = ""
            }
        }
        
        return biometricImage
    }

    
    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available and can be evaluated
        let isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
//        if let error = error {
////             Handle the error, if needed
////            print("Biometric authentication is unavailable. Error: \(error.localizedDescription)")
//        }
        
        return isBiometricAvailable
    }

    func printUrl(){
        if let url = receivedURL {
            // Use the 'url' variable as a non-optional URL in your application
            print(url)
        } else {
            // Handle the case when 'receivedURL' is nil
            print("No URL received")
        }
    }
    
    func sendEmailOtp(email: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/otp/mail/send-otp"
        
        let parameters = """
        {
            "email": "\(email)",
            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
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
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    //self.offLoading()
                    return
                }
                
                if (200...300).contains(responseStatusCode){
                    do {
                        if let jsonData = response.data,
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let otpKey = json["otpKey"] as? String,
                           let prefix = json["prefix"] as? String
                        {
                            //                            print("Otpkey: \(otpKey)")
                            //                            print("Prefix: \(prefix)")
                            self.otpKey = otpKey
                            self.prefix = prefix
                            
                        } else {
                            print("Invalid response format or missing required fields")
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                    }
                }
                else {
                    // Handle the non-redirect response
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        completion(responseStatusCode) // Return the default value on error
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
                completion(responseStatusCode) // Return the actual status code
            }
    }
    
    func sendSMSOtp(mobileNumber: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/otp/mobile/send-otp"
        
        let parameters = """
        {
            "mobile": "852\(mobileNumber)",
            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
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
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    //self.offLoading()
                    return
                }
                
                if (200...300).contains(responseStatusCode){
                    do {
                        if let jsonData = response.data,
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let otpKey = json["otpKey"] as? String,
                           let prefix = json["prefix"] as? String
                        {
                            print("Otpkey: \(otpKey)")
                            print("Prefix: \(prefix)")
                            self.otpKey = otpKey
                            self.prefix = prefix
                            
                        } else {
                            print("Invalid response format or missing required fields")
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                    }
                }
                else {
                    // Handle the non-redirect response
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        completion(responseStatusCode) // Return the default value on error
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
                completion(responseStatusCode) // Return the actual status code
            }
    }

    func verifyOtp(enterOtp: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/otp/validate-otp"
        
        let parameters: String
        
        parameters = """
            {
                "otp": "\(enterOtp)",
                "otpKey": "\(self.otpKey)"
            }
            """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
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
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    return
                }
                
                completion(responseStatusCode)
            }
    }

    
//    func bioAuthenticate(){
//        //self.getTokenByRefresh(refreshToken: KeychainStorage.getCredentials()!.refreshToken)
//
//        Task{
//            do{
//                let context = LAContext()
//                var error : NSError?
//                //let credentials = KeychainStorage.getCredentials()
//                
//                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
//                    
//                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is for security reasons") { success, authenticationError in
//                        
//                        if success{
//                            print("Unlocked")
//                            Task.detached{
//                                self.getTokenByRefresh(refreshToken: KeychainStorage.getCredentials()!.refreshToken){result in
//                                    if result == 0 {
//                                        // Token refresh and createBiometricLoginSession succeeded
//                                    } else if result == 1 {
//                                        // Token refresh expired.
//                                    } else if result == -1 {
//                                        // Token refresh failed.
//                                    }
//                                }
//                            }
//                        }
//                        else{
//                            print("There was a problem!")
//                        }
//                    }
//                }
//                else {
//                    print("Phone does not have Biometrics")
//                }
//            }
//        }
//    }
    
    func bioAuthenticate(completion: @escaping (Int) -> Void) {
        //        Task {
        //            do {
        //                let context = LAContext()
        //
        //                var error: NSError?
        //
        //                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        //                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is for security reasons") { success, authenticationError in
        //                        if success {
        //                            print("Unlocked")
        Task.detached {
            do {            //can get the token
                let credentials = try KeychainStorage.getCredentials()
                Logger.info(data: "got credentials ")
                //                                    self.biometricEnabled = true
                //Logger.info(data: "Read credentials: \(credentials.refreshToken)")
                Logger.info(data: "Get credentials success")
                self.getTokenByRefresh(refreshToken: credentials.refreshToken) {
                    result in
                    if result == 0 {
                        // Token refresh and createBiometricLoginSession succeeded
                        completion(0)
                    } else if result == 1 {
                        // Token refresh expired
                        completion(-3)
                    } else if result == -1 {
                        // Token refresh failed
                        completion(-2)
                    }
                }
            } catch {        //can't get the token
                if let keychainError = error as? KeychainError {
                    if keychainError.status == errSecItemNotFound{
                        Logger.error(data: keychainError.localizedDescription)
                        completion(-1)
                    }
                    else if keychainError.status == errSecAuthFailed{
                        Logger.error(data: keychainError.localizedDescription)
                    }
                }
            }
        }
        //                        } else {
        //                            print("There was a problem!")
        //                            completion(-1)
        //                        }
        //                    }
        //                } else {
        //                    print("Phone does not have Biometrics")
        //                    completion(-1)
        //                }
        //            }
        //        }
    }
        
    func getTokenByRefresh(refreshToken: String, completion: @escaping (Int) -> Void) {
        self.onLoading()
        
        let clientSecret = self.config.clientSecret
        let clientID = self.config.clientID
        
        Task {
            do {
                let metadata = try await self.appauth.fetchMetadata()
                
                let tokenResponse = try await self.appauth.refreshAccessToken(
                    metadata: metadata,
                    clientID: clientID,
                    clientSecret: clientSecret,
                    refreshToken: refreshToken)
                
                await MainActor.run {
                    self.offLoading()
                    if let tokenResponse = tokenResponse {
                        createBiometricLoginSession(idToken: tokenResponse.idToken!)
                        completion(0)
                    } else {
                        completion(1)
                    }
                }
            } catch {
                await MainActor.run {
                    let appError = error as? ApplicationError
                    if let appError = appError {
                        self.offLoading()
                        print(appError)
                        completion(-1)
                    }
                }
            }
        }
    }
    
    func createBiometricLoginSession(idToken: String) {
        self.onLoading()
        
        let endpoint = "\(self.config.authorizationEndpoint)"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.offlineScope)"
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
        
    func getFirstPartyTokenBycode(Code: String, isThirdParty: Bool){
        Task{
            do{
                self.onLoading()
                
                let metadata = try await self.appauth.fetchMetadata()
                
                let redirectUrl = try self.config.getRedirectUri()
                
                let clientSecret = self.config.clientSecret
                
                let scope = self.config.scope
                                
                let tokenResponse = try await self.appauth.getTokensByCode(code: Code, metadata: metadata, clientID: self.config.clientID, codeVerifier: nil, redirectUrl: redirectUrl, scope: scope, clientSecret: clientSecret)
                
                await MainActor.run {
                    self.state.metadata = metadata
                    self.state.saveTokens(tokenResponse: tokenResponse)
                    if let url = self.state.url{
                        self.genCodeAndOpenApp2(idToken: tokenResponse.idToken!, url: url, isThirdParty: isThirdParty)
                    }
                    self.offLoading()
                    //self.onLoggedIn()
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
                }
            }
        }
    }
    
    func genCodeAndOpenApp2(idToken: String, url: URL, isThirdParty: Bool){
        
        let headers: HTTPHeaders = [
            //"Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Bearer \(idToken)"
        ]
        let redirector = Redirector(behavior: .doNotFollow)
        // Set the redirect URL parameter
        //print(url)
        session.request(url, method: .get, encoding: URLEncoding.default, headers: headers)
            .validate()
            .redirect(using: redirector)
            .response { response in
                // Handle the response manually
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    return
                }
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    // Handle the redirect URL
                    print("Redirect URL: \(redirectURL)")
                    
                    if let components = URLComponents(string: redirectURL),
                       let queryItems = components.queryItems {
                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
                            // Extracted code parameter
                            print("Code: \(code)")
                            
                            let targetAppURLScheme = "com.ksm.kevin.app2"
                            
                            if(isThirdParty){
                                let url = URL(string: "\(targetAppURLScheme)://?code3=\(code)")!
                                UIApplication.shared.open(url)

                            }
                            else{
                                let url = URL(string: "\(targetAppURLScheme)://?code=\(code)")!
                                UIApplication.shared.open(url)
                            }
                            
                            self.state.url = nil
                                                        
                        }
                    }
                    // Perform additional actions or make a new request if necessary
                } else {
                    // Handle the non-redirect response
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }

    func disableBiometric(){
        Task.detached{
            print("Unlocked")
            do{
                try KeychainStorage.deleteCredentials()
                Logger.info(data: "Deleted credentials")
            }
            catch{
                if let error = error as? KeychainError {
                    Logger.error(data: error.localizedDescription)
                }
            }
        }
    }
    
    struct TokenResponse: Decodable {
        let id_token: String
        let access_token: String
        let refresh_token: String
        let expires_in: Int
//        let error: String
//        let error_description : String
    }

    func sendAuthenticationRequestLab(username: String, password: String, completion: @escaping (Int) -> Void) {
        self.onLoading()
        let url = "\(self.config.authorizationEndpoint)"
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)",
            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
        ]
        
        print(parameters)
        
        let base64String = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(base64String)",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            //.validate()
            .redirect(using: redirector)
            .response { response in
                // Handle the response manually
                self.offLoading()
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    //self.offLoading()
                    return
                }
                
                if (200...300).contains(responseStatusCode){
                    do {
                        if let jsonData = response.data,
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           //let type = json["type"] as? String,
                           let otpKey = json["otpKey"] as? String,
                           let prefix = json["prefix"] as? String
                        {
                            print("Otpkey: \(otpKey)")
                            self.otpKey = otpKey
                            self.prefix = prefix
                            
                            if let email = json["email"] as? String {
                                print("Email: \(email)")
                                self.type = "email"
                                // Handle email type response here
                            } else if let mobileNumber = json["mobileNumber"] as? String {
                                print("Mobile Number: \(mobileNumber)")
                                self.mobileNumber = mobileNumber
                                self.type = "sms"
                                // Handle SMS type response here
                            } else {
                                print("Invalid response format or missing required fields")
                            }
                            
                        } else {
                            print("Invalid response format or missing required fields")
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                    }
                }
                else {
                    // Handle the non-redirect response
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        completion(responseStatusCode) // Return the default value on error
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
                completion(responseStatusCode) // Return the actual status code
            }
    }

    func sendAuthenticationRequestWithOtp(username: String, password: String, otp: String, completion: @escaping (Int) -> Void) {
        self.onLoading()
        let url = "\(self.config.authorizationEndpoint)"
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)",
            "code": "\(otp)",
            "otpKey": "\(self.otpKey)"
        ]
        
        let base64String = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(base64String)",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)
        
        session.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .redirect(using: redirector)
            .response { response in
                // Handle the response manually
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return a default value to indicate an error
                    return
                }
                
                completion(statusCode) // Return the status code
                
                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
                    // Handle the redirect URL
                    print("Redirect URL: \(redirectURL)")
                    
                    if let components = URLComponents(string: redirectURL),
                       let queryItems = components.queryItems {
                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
                            // Extracted code parameter
                            print("Code: \(code)")
                            self.getFirstPartyTokenBycode(Code: code, isThirdParty: false)
                        }
                    }
                    
                } else {
                    // Handle the non-redirect response
                    guard let data = response.data else {
                        print("Error: \(String(describing: response.error))")
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                }
            }
    }

}


