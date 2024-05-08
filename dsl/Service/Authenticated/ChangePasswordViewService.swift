//
//  ChangePasswordViewService.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import Foundation
import Alamofire

class ChangePasswordViewService: AuthenticatedViewService{
    
    //@Published var userModel : UserModel?

    func checkEmail(completion: @escaping (Bool) -> Void) {
        
        self.processTokens()
        
        let endpoint = "\(self.config.policeIP)/sso-user-api/mobile/users/\(self.idTokenClaims!.sub)"

        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
        ]
                
        self.onLoading()
        
        session.request(endpoint, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserModel.self){ response in
                // Handle the response manually
                self.offLoading()
                                
                switch response.result {
                case .success(let userModel):
                    self.userModel = userModel
                    if let email = userModel.email{
                        if !email.isEmpty {
                            completion(true)
                        }
                        else{
                            completion(false)
                        }
                    }
                    else{
                        completion(false)
                    }
                case .failure(let error):
                    self.userModel = nil
                    Logger.info(data: "User Model Not Found")
                    print("Request failed with error: \(error)")
                    completion(false) // Handle network errors
                }
                self.offLoading()
            }

//        if(self.idTokenClaims?.email != nil){
//            completion(true)
//        }
//        else{
//            completion(false)
//        }
    }
    
    func checkHaveCredentials(completion: @escaping (Bool) -> Void){
        
        self.processTokens()
        
        let endpoint = "\(self.config.policeIP)/sso-user-api/users/checkCredentials/\(self.idTokenClaims!.sub)"

        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
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
                self.offLoading()
            }
    }
    
    func checkOldPassword(password: String, completion: @escaping (Int) -> Void) {
        self.onLoading()
        
        let url = "\(self.config.authorizationEndpoint)"
        
        let parameters: [String: Any] = [
            "response_type": "code",
            "client_id": "\(self.config.clientID)",
            "redirect_uri": "\(self.config.redirectUri)",
            "scope": "\(self.config.scope)",
            "verifyPasswordMode": "on"
        ]
        
        //print(parameters)
        
        //print(self.userModel!.username)
        let base64String = "\(self.userModel!.username):\(password)".data(using: .utf8)!.base64EncodedString()
        
        //print(password)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(base64String)",
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]
        
        let redirector = Redirector(behavior: .doNotFollow)
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        session.request(url, method: .post, parameters: parameters, headers: headers)
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
                //print(responseStatusCode)
                completion(responseStatusCode) // Return the actual status code
            }
    }
    
    func ChangeNewPassword(password: String, completion: @escaping (Int) -> Void){
        
        self.onLoading()
        
        let endpoint = "\(self.config.umsEndpoint)/sso-user-api/users/changePassword/\(self.idTokenClaims!.sub)"
        
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)",
            "Authorization": "Bearer \(self.idToken)"
        ]

        let parameters = """
        {
            "type": "password",
            "value": "\(password)",
            "temporary": false
        }
        """
        
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
