//
//  ProfileUpdateViewService.swift
//  dsl
//
//  Created by chuang chin yuen on 19/2/2024.
//

import Foundation
import Alamofire

class ProfileUpdateViewService: AuthenticatedViewService{
    
    @Published var mailOtpKey = ""
    
    @Published var smsOtpKey = ""

    @Published var mailOtpPrefix = ""
    
    @Published var smsOtpPrefix = ""
    
    @Published var emailIdentifier = ""

    @Published var mobileIdentifier = ""
    
    //@Published var userModel : UserModel?

    override func getUserProfile(completion: @escaping (Bool) -> Void) {
        
        emailIdentifier = ""
        
        mobileIdentifier = ""
        
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
    
    func checkUniqueEmail(email: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/users/email/unique/\(email)"
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]

        self.onLoading()
        
        session.request(endpoint, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseString { response in
                self.offLoading()
                switch response.result {
                case .success(let value):
                    let isUnique = (value.lowercased() == "true")
                    completion(isUnique)
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(false)
                }
            }
    }
    
    func checkUniqueSMS(mobile: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/users/mobile/unique/\(mobile)"
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]

        self.onLoading()
        
        session.request(endpoint, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseString { response in
                self.offLoading()
                switch response.result {
                case .success(let value):
                    let isUnique = (value.lowercased() == "true")
                    completion(isUnique)
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(false)
                }
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
                            self.mailOtpKey = otpKey
                            self.mailOtpPrefix = prefix
                            
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

    
    func verifyOtp(type: Int, userInfo: String, enterOtp: String, completion: @escaping (Int) -> Void){
        let endpoint = "\(self.config.umsEndpoint)/sso-common-api/mobile/otp/update-profile/validate-otp"
        
        
        let parameters: String

        if type == 1 {                         //email
            parameters = """
            {
                "otp": "\(enterOtp)",
                "otpKey": "\(self.mailOtpKey)",
                "email": "\(userInfo)"
            }
            """
        } else if type == 2 {                 //sms
            parameters = """
            {
                "otp": "\(enterOtp)",
                "otpKey": "\(self.smsOtpKey)",
                "mobile": "852\(userInfo)"
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
                           let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           //let type = json["type"] as? String,
                           let identifier = json["identifier"] as? String
                        {
                            print("identifier: \(identifier)")
                            if type == 1{
                                self.emailIdentifier = identifier
                            }
                            else if type == 2{
                                self.mobileIdentifier = identifier
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
    
    func UserProfileUpdate(userModel: UserModel, completion: @escaping (Int) -> Void){
        
        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/mobile/users/\(self.idTokenClaims!.sub)"
        
        let parameters = """
        {
            "emailIdentifier": "\(self.emailIdentifier)",
            "mobileIdentifier": "\(self.mobileIdentifier)",
            "user": {
                           "username": "\(userModel.email!.isEmpty ? self.userModel!.username : userModel.email!)",
                           "firstName": "\(userModel.firstName)",
                           "lastName": "\(userModel.lastName)",
                           "email": "\(userModel.email!)",
                           "emailVerified": \(userModel.emailVerified ?? true),
                           "attributes": {
                               "oldSub": \(self.userModel!.attributes.oldSub ?? [""]),
                               "mobileCountryCode": \(userModel.attributes.mobileCountryCode),
                               "mobileNumber": \(userModel.attributes.mobileNumber),
                               "chineseName": \(userModel.attributes.chineseName),
                               "mailingAddress": \(userModel.attributes.mailingAddress),
                               "hkidNumber": \(userModel.attributes.hkidNumber),
                               "dateOfBirth": \(userModel.attributes.dateOfBirth),
                               "gender": \(userModel.attributes.gender),
                               "areaOfResidence": \(userModel.attributes.areaOfResidence),
                               "company": \(userModel.attributes.company),
                               "post": \(userModel.attributes.post),
                               "occupation": \(userModel.attributes.occupation),
                               "identityDocumentCountry": \(userModel.attributes.identityDocumentCountry),
                               "identityDocumentType": \(userModel.attributes.identityDocumentType),
                               "identityDocumentValue": \(userModel.attributes.identityDocumentValue),
                               "iAMSmartTokenisedId" : \(self.userModel!.attributes.iAMSmartTokenisedId),
                               "authLevel": \(self.userModel!.attributes.authLevel),
                               "maxAuthLevel": \(userModel.attributes.maxAuthLevel),
                               "locale": \(userModel.attributes.locale),
                               "lastLogin": \(self.userModel!.attributes.lastLogin!),
                               "latestLogin": \(self.userModel!.attributes.latestLogin!)
                           }
            }
        }
        """
        
        print(parameters)
                
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
        ]
        
        guard let jsonData = parameters.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Invalid parameters JSON")
            return
        }
        
        self.onLoading()
        session.request(endpoint, method: .put, parameters: json, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300) // Validate the response status code
            .response { response in
                self.offLoading()
                guard let statusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    completion(-1) // Return a default value to indicate an error
                    return
                }
                completion(statusCode)
                switch response.result {
                case .success:
                    // Request succeeded with status code 201
                    print(statusCode)
                    print("User profiled updated successfully")
                case .failure(let error):
                    // Request failed or status code is not within the desired range
                    print("Request failed with error: \(error)")
                }
            }
    }
    
        
}
