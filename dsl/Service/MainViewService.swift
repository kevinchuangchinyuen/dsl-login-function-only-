//
//  MainViewModel.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import Network
import Alamofire
import SwiftUI


struct Content: Decodable {
    let content_en: String
    let content_zh_hk: String
    let content_zh_cn: String
}

class MainViewService: ObservableObject {

    
    @Published var isNetworkAvailable = true
    @Published var isSupportediOSVersion = true
    @Published var isNotJailbroken = true
    @Published var isSupportedAppVersion = true

    @Published var isAuthenticated = false
    @Published var isFirstTimeLogin = false
    @Published var isLoading = false
    
    let requiredAppVersion = "1.0.0" // Specify the minimum required app version

    private let config: ApplicationConfig
    let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private var unauthenticatedService: UnauthenticatedViewService?
    private var authenticatedService: AuthenticatedViewService?
//    private var firstTimeLoginModel: FirstTimeLoginModel?
    
    private let session: Session

    init() {
        self.state = ApplicationStateManager()
        self.config = try! ApplicationConfigLoader.load()
        self.appauth = AppAuthHandler(config: self.config)
        // These are created on first use
        self.unauthenticatedService = nil
        self.authenticatedService = nil
//        self.firstTimeLoginModel = nil
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
    }
    
    func getPublicIpAddress(completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://api.ipify.org"

        AF.request(url).responseString { response in
            switch response.result {
            case .success(let ipAddress):
                completion(.success(ipAddress))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func checkNetwork() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isNetworkAvailable = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkiOSVersion() {
        if #available(iOS 14.0, *) {
            isSupportediOSVersion = true
        } else {
            isSupportediOSVersion = false
        }
    }
    
    func checkAppVersion() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            isSupportedAppVersion = false
            return
        }
        isSupportedAppVersion = appVersion >= requiredAppVersion
    }

    func checkJailbreak() {
//        if let cydiaURL = URL(string: "cydia://package/com.example.package") {
//            isNotJailbroken = UIApplication.shared.canOpenURL(cydiaURL)
//        } else {
//            isNotJailbroken = false
//        }
        
        do {
            let pathToFileInRestrictedDirectory = "/private/jailbreak.txt"
            try "This is a test.".write(toFile: pathToFileInRestrictedDirectory, atomically: true, encoding: String.Encoding.utf8)
            try FileManager.default.removeItem(atPath: pathToFileInRestrictedDirectory)
            isNotJailbroken = false
            // Device is jailbroken
        } catch {
            isNotJailbroken = true
        }

    }
    
    func performValidation() {
        checkNetwork()
        checkiOSVersion()
        checkAppVersion()
        checkJailbreak()
    }

    func getUnauthenticatedViewService() -> UnauthenticatedViewService {
        
        if self.unauthenticatedService == nil {
            self.unauthenticatedService = UnauthenticatedViewService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoading: self.onLoading,
                offLoading: self.offLoading,
                onFirstTimeLogin: self.onFirstTimeLogin)
        }

        return self.unauthenticatedService!
    }
    
    func getAuthenticatedViewService() -> AuthenticatedViewService {
        
        if self.authenticatedService == nil {
            self.authenticatedService = AuthenticatedViewService(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut,
                onLoading: self.onLoading,
                offLoading: self.offLoading)
        }

        return self.authenticatedService!
    }
    
    func getFooterInfo(number: Int, completion: @escaping (Content) -> Void){
        
        let endpoint: String
        
        if number == 1{
            endpoint = "\(self.config.umsEndpoint)/sso-common-api/common-mobile/get-disclaimer"
        }
        else if number == 2{
            endpoint = "\(self.config.umsEndpoint)/sso-common-api/common-mobile/get-privacy-policy"
        }
        else if number == 3{
            endpoint = "\(self.config.umsEndpoint)/sso-common-api/common-mobile/get-faq"
        }
        else if number == 4{
            endpoint = "\(self.config.umsEndpoint)/sso-common-api/common-mobile/get-announcement"
            //endpoint = "https://192.168.101.63/sso-common-api/common-mobile/get-announcement"
        }
        else{
            endpoint = "\(self.config.umsEndpoint)/sso-common-api/common-mobile/get-faq"
        }
                
        let headers: HTTPHeaders = [
            //"X-Forwarded-For": "\(self.state.getSetIpAddress)"
        ]

        self.onLoading()
                
        session.request(endpoint, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Content.self){ response in
                // Handle the response manually
                self.offLoading()
                
                guard let responseStatusCode = response.response?.statusCode else {
                    print("Error: \(String(describing: response.error))")
                    //self.offLoading()
                    return
                }
                
                switch response.result {
                case .success(let Content):
                    completion(Content)
                case .failure(let _error):
                    Logger.info(data: "Content Model Not Found")
                }
                
            }
    }
    
//    func getFirstTimeLoginModel() -> FirstTimeLoginModel {
//        
//        if self.firstTimeLoginModel == nil{
//            self.firstTimeLoginModel = FirstTimeLoginModel(
//                config: self.config,
//                state: self.state,
//                offFirstTimeLogin: self.offFirstTimeLogin)
//        }
//        
//        return self.firstTimeLoginModel!
//    }
    
//    func onLoggedIn() {
//        self.isAuthenticated = true
//    }
//
    func onLoggedOut() {
        self.isAuthenticated = false
    }
    
    func onFirstTimeLogin(){
        self.isFirstTimeLogin = true
    }

    func offFirstTimeLogin(){
        self.isFirstTimeLogin = false
    }
    
    func onLoading(){
        self.isLoading = true
    }

    func offLoading(){
        self.isLoading = false
    }

}
