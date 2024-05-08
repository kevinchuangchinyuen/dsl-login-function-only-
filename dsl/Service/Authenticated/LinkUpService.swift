//
//  LinkUpService.swift
//  dsl
//
//  Created by chuang chin yuen on 1/3/2024.
//

import Foundation
import Alamofire
import SwiftJWT

class LinkUpService: AuthenticatedViewService{
    
    @Published var otpKey: String = ""
    
    @Published var type: String = ""
    
    @Published var prefix: String = ""
    
    @Published var mobileNumber: String = ""
    
    //@Published var userModel : UserModel?
    
    @Published var linkUpModel : LinkUpModel?

    @Published var authCode: String = ""

    func linkUpAuth(username: String, password: String, completion: @escaping (Int) -> Void){
        
        //HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        self.onLoading()
        
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/linkUpUser/auth"

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        let parameters = """
        {
            "username": "\(username)",
            "password": "\(password)",
            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
        }
        """

        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }

        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .response{ response in
            
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
                           let prefix = json["prefix"] as? String {
                            
                            self.otpKey = otpKey
                            self.prefix = prefix
                            
                            if let mobileNumber = json["mobile"] as? String {
                                print("Mobile Number: \(mobileNumber)")
                                self.mobileNumber = mobileNumber
                                self.type = "sms"
                                // Handle SMS type response here
                            } else {
                                self.type = "email"
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
    
    func verifyOtp(username: String, enterOtp: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/linkUpUser/validate-otp"
        
        let parameters: String

        parameters = """
        {
            "email": "\(username)",
            "otp": "\(enterOtp)",
            "otpKey": "\(self.otpKey)"
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
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LinkUpModel.self) {response in
                // Handle the response manually
                self.offLoading()
                            
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return the default value on error
                    return
                }
                
                switch response.result {
                case .success(let linkUpModel):
                    self.linkUpModel = linkUpModel
                    print(linkUpModel)
                case .failure(let _error):
                    self.linkUpModel = nil
                    Logger.info(data: "Linkup Model Not Found")
                }
                completion(responseStatusCode)
            }
    }
    
    func linkUp(username: String, password: String, iamSmartAccountSub: String, iamSmartAccountToken: String, isFirstTimeLink: Bool, completion: @escaping (Bool) -> Void){
                
        //self.processTokens()
        
        self.onLoading()
        
        let endpoint: String
        
        if isFirstTimeLink{
            endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users/first-login/link-up-dsl/\(iamSmartAccountSub)/\(self.linkUpModel!.user.id)"
        }
        else{
            endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users/linkUpUser/\(iamSmartAccountSub)/\(self.linkUpModel!.user.id)"
        }
        
        let parameters = """
        {
            "identifier": "\(self.linkUpModel!.identifier)",
            "password": "\(password)"
        }
        """
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(iamSmartAccountToken)",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }
                
        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                self.offLoading()
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    // Return the default value on error
                    //self.offLoading()
                    return
                }
                if (200...300).contains(responseStatusCode){
                    completion(true)
                }
                else{
                    print(responseStatusCode)
                }
            }
    }
    
}


struct BodyStringEncoding: ParameterEncoding {
    private let body: String

    init(body: String) { self.body = body }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        guard let data = body.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        return urlRequest
    }
}

extension BodyStringEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyStringEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .emptyURLRequest: return "Empty url request"
            case .encodingProblem: return "Encoding problem"
        }
    }
}


//    override func processTokens() {
//        do {
//            print(self.idToken)
//            let jwt = try JWT<IDTokenClaims>(jwtString: self.idToken)
//            self.idTokenClaims = jwt.claims
//            print(self.idTokenClaims!)
//
//        } catch {
//            print(error)
//        }
//    }
//
//    override func getUserProfile(completion: @escaping (Bool) -> Void) {
//
//        self.processTokens()
//
//        let endpoint = "\(self.config.policeIP)/sso-user-api/mobile/users/\(self.idTokenClaims!.sub)"
//
//        let headers: HTTPHeaders = [
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
//            "Authorization": "Bearer \(self.idToken)"
//        ]
//
//        print(endpoint)
//
//        self.onLoading()
//
//        session.request(endpoint, method: .get, headers: headers)
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: UserModel.self){ response in
//                // Handle the response manually
//                self.offLoading()
//
//                guard let responseStatusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(false) // Return the default value on error
//                    return
//                }
//
//                switch response.result {
//                case .success(let userModel):
//                    self.userModel = userModel
//                    print(userModel)
//                    completion(true)
//                case .failure(let _error):
//                    self.userModel = nil
//                    Logger.info(data: "User Model Not Found")
//                    completion(false) // Handle network errors
//                }
//            }
//    }


//    func sendAuthenticationRequestLab(username: String, password: String, completion: @escaping (Int) -> Void) {
//
//        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
//
//        self.onLoading()
//        let url = "\(self.config.authorizationEndpoint)"
//
//        let parameters: [String: Any] = [
//            "response_type": "code",
//            "client_id": "\(self.config.clientID)",
//            "redirect_uri": "\(self.config.redirectUri)",
//            "scope": "\(self.config.scope)"
//        ]
//
//        let base64String = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
//
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/x-www-form-urlencoded",
//            "Authorization": "Basic \(base64String)",
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
//        ]
//
//        let redirector = Redirector(behavior: .doNotFollow)
//
//        session.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
//            //.validate()
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: LinkUpModel.self){ response in
//                // Handle the response manually
//                self.offLoading()
//
//                guard let responseStatusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(false) // Return the default value on error
//                    return
//                }
//
//                switch response.result {
//                case .success(let userModel):
//                    self.userModel = userModel
//                    print(userModel)
//                    completion(true)
//                case .failure(let _error):
//                    self.userModel = nil
//                    Logger.info(data: "User Model Not Found")
//                    completion(false) // Handle network errors
//                }
//            }
//    }
//
//    func sendAuthenticationRequestWithOtp(username: String, password: String, otp: String, completion: @escaping (Int) -> Void) {
//        self.onLoading()
//        let url = "\(self.config.authorizationEndpoint)"
//
//        let parameters: [String: Any] = [
//            "response_type": "code",
//            "client_id": "\(self.config.clientID)",
//            "redirect_uri": "\(self.config.redirectUri)",
//            "scope": "\(self.config.scope)",
//            "code": "\(otp)",
//            "otpKey": "\(self.otpKey)"
//        ]
//
//        let base64String = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
//
//        let headers: HTTPHeaders = [
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
//            "Content-Type": "application/x-www-form-urlencoded",
//            "Authorization": "Basic \(base64String)"
//        ]
//
//        let redirector = Redirector(behavior: .doNotFollow)
//
//        session.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
//            .redirect(using: redirector)
//            .response { response in
//                // Handle the response manually
//                self.offLoading()
//                guard let statusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(-1) // Return a default value to indicate an error
//                    return
//                }
//
//                 // Return the status code
//
//                if (300...399).contains(statusCode), let redirectURL = response.response?.allHeaderFields["Location"] as? String {
//                    // Handle the redirect URL
//                    print("Redirect URL: \(redirectURL)")
//
//                    if let components = URLComponents(string: redirectURL),
//                       let queryItems = components.queryItems {
//                        if let code = queryItems.first(where: { $0.name == "code" })?.value {
//                            // Extracted code parameter
//                            print("Code: \(code)")
//                            self.authCode = code
////                            self.getFirstPartyTokenBycode(Code: code, isThirdParty: false)
//                        }
//                    }
//
//                } else {
//                    // Handle the non-redirect response
//                    guard let data = response.data else {
//                        print("Error: \(String(describing: response.error))")
//                        return
//                    }
//                    print(String(data: data, encoding: .utf8)!)
//                }
//                completion(statusCode)
//            }
//    }
//
//    func getFirstPartyTokenBycode(Code: String, isThirdParty: Bool, completion: @escaping (Bool) -> Void){
//        Task{
//            do{
//                self.onLoading()
//
//                let metadata = try await self.appauth.fetchMetadata()
//
//                let redirectUrl = try self.config.getRedirectUri()
//
//                let clientSecret = self.config.clientSecret
//
//                let scope = self.config.scope
//
//                let tokenResponse = try await self.appauth.getTokensByCode(code: Code, metadata: metadata, clientID: self.config.clientID, codeVerifier: nil, redirectUrl: redirectUrl, scope: scope, clientSecret: clientSecret)
//
//                await MainActor.run {
//                    self.idToken = tokenResponse.idToken!
//                    self.accessToken = tokenResponse.accessToken!
//                    self.offLoading()
//                    completion(true)
//                }
//            }
//            catch{
//                await MainActor.run {
//                    let appError = error as? ApplicationError
//                    if appError != nil {
//                        //self.error = appError!
//                        print(appError as Any)
//                    }
//                    self.offLoading()
//                }
//            }
//        }
//    }
//
//    func sendEmailOtp(email: String, completion: @escaping (Int) -> Void){
//        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/otp/mail/send-otp"
//
//        let parameters = """
//        {
//            "email": "\(email)",
//            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
//        }
//        """
//
//        let headers: HTTPHeaders = [
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
//        ]
//
//        self.onLoading()
//
//        guard let jsonData = parameters.data(using: .utf8),
//              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
//            print("Invalid parameters JSON")
//            return
//        }
//
//        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
//        //.validate(statusCode: 200..<300)
//            .response{ response in
//                // Handle the response manually
//                self.offLoading()
//
//                guard let responseStatusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(-1) // Return the default value on error
//                    //self.offLoading()
//                    return
//                }
//
//                if (200...300).contains(responseStatusCode){
//                    do {
//                        if let jsonData = response.data,
//                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//                           let otpKey = json["otpKey"] as? String,
//                           let prefix = json["prefix"] as? String
//                        {
//                            //                            print("Otpkey: \(otpKey)")
//                            //                            print("Prefix: \(prefix)")
//                            self.otpKey = otpKey
//                            self.prefix = prefix
//
//                        } else {
//                            print("Invalid response format or missing required fields")
//                        }
//                    } catch {
//                        print("Failed to parse response JSON: \(error)")
//                    }
//                }
//                else {
//                    // Handle the non-redirect response
//                    guard let data = response.data else {
//                        print("Error: \(String(describing: response.error))")
//                        completion(responseStatusCode) // Return the default value on error
//                        return
//                    }
//                    print(String(data: data, encoding: .utf8)!)
//                }
//                completion(responseStatusCode) // Return the actual status code
//            }
//    }
//
//    func sendSMSOtp(mobileNumber: String, completion: @escaping (Int) -> Void){
//        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/otp/mobile/send-otp"
//
//        let parameters = """
//        {
//            "mobile": "852\(mobileNumber)",
//            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
//        }
//        """
//
//        let headers: HTTPHeaders = [
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
//        ]
//
//        self.onLoading()
//
//        guard let jsonData = parameters.data(using: .utf8),
//              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
//            print("Invalid parameters JSON")
//            return
//        }
//
//        session.request(endpoint, method: .post, parameters: json, encoding: JSONEncoding.default, headers: headers)
//        //.validate(statusCode: 200..<300)
//            .response{ response in
//                // Handle the response manually
//                self.offLoading()
//
//                guard let responseStatusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(-1) // Return the default value on error
//                    //self.offLoading()
//                    return
//                }
//
//                if (200...300).contains(responseStatusCode){
//                    do {
//                        if let jsonData = response.data,
//                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//                           let otpKey = json["otpKey"] as? String,
//                           let prefix = json["prefix"] as? String{
//                            print("Otpkey: \(otpKey)")
//                            print("Prefix: \(prefix)")
//                            self.otpKey = otpKey
//                            self.prefix = prefix
//                        } else {
//                            print("Invalid response format or missing required fields")
//                        }
//                    } catch {
//                        print("Failed to parse response JSON: \(error)")
//                    }
//                }
//                else {
//                    // Handle the non-redirect response
//                    guard let data = response.data else {
//                        print("Error: \(String(describing: response.error))")
//                        completion(responseStatusCode) // Return the default value on error
//                        return
//                    }
//                    print(String(data: data, encoding: .utf8)!)
//                }
//                completion(responseStatusCode) // Return the actual status code
//            }
//    }
    
