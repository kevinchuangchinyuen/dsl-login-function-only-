//
//  ForgotPasswordService.swift
//  dsl
//
//  Created by chuang chin yuen on 16/2/2024.
//

import Foundation
import Alamofire
import SwiftUI

class ForgotPasswordViewService: UnauthenticatedViewService{
        
    @Published var mailOtpKey = ""
    
    @Published var smsOtpKey = ""

    @Published var mailOtpPrefix = ""
    
    @Published var smsOtpPrefix = ""
    
    @Published var email = ""
    
    @Published var mobile = ""
    
    @Published var identifier = ""
    
    @Published var haveHkMobileNumber = false
    
    @Published var userExist = false

//
//    @Published private var mobile = ""
    
 //   @Published private var isVaildUser: Bool = false
    
//    @Published var userResponse: UserResponse?
        
    struct UserResponse: Decodable {
        let id: String
        let email: String
        let attributes: Attributes
    }

    struct Attributes: Decodable {
        let mobileCountryCode: [String]
        let mobileNumber: [String]
    }
    
//    func getUserByEmail(email: String, completion: @escaping (Int) -> Void) {
//        self.onLoading()
//        
//        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/users/email/\(email)"
//        
//        let headers: HTTPHeaders = [
//            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
//        ]
//        
//        session.request(endpoint, method: .get, headers: headers)
//            .responseDecodable(of: UserResponse.self) { response in
//                self.offLoading()
//                
//                guard let responseStatusCode = response.response?.statusCode else {
//                    print("Error: \(String(describing: response.error))")
//                    completion(-1) // Return the default value on error
//                    //self.offLoading()
//                    return
//                }
//                                
//                switch response.result {
//                case .success(let userResponse):
//                        //self.isVaildUser = true
////                        self.email = userResponse.email
////                        if let mobileNumber  = userResponse.attributes.mobileNumber[0] {
////                            self.mobile = mobileNumber
////                        }
//                        self.userResponse = userResponse
//                        print(userResponse)
//                        completion(responseStatusCode)
//                case .failure(let _error):
//                    self.userResponse = nil
//                    self.mailOtpPrefix = ""
//                    self.smsOtpPrefix = ""
//                    Logger.info(data: "User Not Found")
//                    completion(responseStatusCode) // Handle network errors
//                }
//                
//            }
//    }
    
    func generateRandomCapitalLetters() -> String {
        var randomString = ""
        for _ in 0..<4 {
            let randomValue = UInt32(arc4random_uniform(26)) + 65 // Generates a random number between 65 and 90 (ASCII values for capital letters)
            let randomCharacter = Character(UnicodeScalar(randomValue)!)
            randomString.append(randomCharacter)
        }
        return randomString
    }

    func sendEmailOtp(completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/otp/mail/send-otp"
        
        let parameters = """
        {
            "email": "\(self.email)",
            "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
        }
        """
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]

        self.email = email
        
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
                    self.userExist = true
                    do {
                        if let jsonData = response.data,
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let otpKey = json["otpKey"] as? String,
                           let prefix = json["prefix"] as? String
                        {
                            self.mailOtpKey = otpKey
                            self.mailOtpPrefix = prefix
                        } else {
                            print("Invalid response format or missing required fields")
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                    }
                }
                else if responseStatusCode == 404{
                    print("No user exist!")
                    self.userExist = false
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
    
    func sendSMSOtp(completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/otp/sms/send-otp"
        
        let parameters = """
        {
            "email": "\(self.email)",
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
                            self.smsOtpKey = otpKey
                            self.smsOtpPrefix = prefix
                            
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

    
    func verifyOtp(type: Int, enterOtp: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/otp/forgot-password/validate-otp"
        
        
        let parameters: String

        if type == 1 {
            parameters = """
            {
                "email": "\(self.email)",
                "otp": "\(enterOtp)",
                "otpKey": "\(self.mailOtpKey)",
                "locale": "\(Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? "")"
            }
            """
        } else if type == 2 {
            parameters = """
            {
                "email": null,
                "otp": "\(enterOtp)",
                "otpKey": "\(self.smsOtpKey)"
            }
            """
        } else {
            parameters = """
            {
                "otp": "\(enterOtp)",
                "otpKey": "\(self.mailOtpKey)"
            }
            """
        }

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
                    return
                }
                
                if (200...300).contains(responseStatusCode){
                    do {
                        if let jsonData = response.data,
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        {
                            if let identifier = json["identifier"] as? String {
                                print("Identifier: \(identifier)")
                                self.identifier = identifier
                                self.haveHkMobileNumber = false
                            } else if let mobileNumber = json["mobile"] as? String,
                                      let otpKey = json["otpKey"] as? String,
                                      let prefix = json["prefix"] as? String {
                                print("Mobile Number: \(mobileNumber)")
                                print("OTP Key: \(otpKey)")
                                print("Prefix: \(prefix)")
                                self.mobile = mobileNumber
                                self.smsOtpKey = otpKey
                                self.smsOtpPrefix = prefix
                                self.haveHkMobileNumber = true
                                // Handle mobile number, OTP key, and prefix here
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
                
                completion(responseStatusCode)
            }
    }
    
    func assignPassword(password: String, completion: @escaping (Int) -> Void){
        self.onLoading()

        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users/resetPassword/\(self.email)"
        
        let parameters = """
        {
            "identifier": "\(self.identifier)",
            "userCredential": {
                "type": "password",
                "value": "\(password)",
                "temporary": false
            }
        }
        """
        
        print(parameters)
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }

        session.request(endpoint, method: .put, parameters: json, encoding: JSONEncoding.default, headers: headers)
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
    
}
