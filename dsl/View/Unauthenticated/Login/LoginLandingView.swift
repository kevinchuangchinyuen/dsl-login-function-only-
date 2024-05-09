//
//  ContentView.swift
//  dsl
//
//  Created by chuang chin yuen on 16/1/2024.
//

import SwiftUI
import LocalAuthentication
import Combine

struct LoginLandingView: View {
    
    @ObservedObject var service: UnauthenticatedViewService

    @EnvironmentObject var localizationManager: LocalizationManager
    @Binding var email : String
    @Binding var password : String
    @Binding var currentState: LoginState
    
    @State private var isEmailError: Bool = false
    @State private var EmailErrorMessage: String = ""
    
    @State private var isPasswordError: Bool = false
    @State private var PasswordErrorMessage: String = ""
    
    @State private var isPasswordEditing: Bool = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer().frame(height: 10)
                    
                    HStack{
                        HeaderView()
                        Spacer()
                        UnauthenticatedMenuButton()
                    }
                    
                    Spacer().frame(height: 10)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        VStack{
                            
                            Spacer().frame(height: 25)
                            
                            Text("login.DigitalServicesLogon".localized(localizationManager.language))
                                .titleStyle()
                            
                            Spacer().frame(height: 35)
                            
                            VStack(alignment: .leading){
                                TextField("login.YourEmail".localized(localizationManager.language), text: $email, onEditingChanged: { isEditing in
                                    if !isEditing {
                                        onEmailChecking()
                                    }
                                })
                                .customLoginField(color: isEmailError ? .red: .gray)
                                .keyboardType(.emailAddress)
                                
                                if(isEmailError){
                                    Text(EmailErrorMessage)
                                        .errorStyle()
                                }
                            }
                            
                            VStack(alignment: .leading){
                                SecureInputNoEyesView(inputTitleValue: "login.Password".localized(localizationManager.language),inputValue: $password, color: isPasswordError ? .red: .gray, onChecking: onPasswordChecking)

                                if(isPasswordError){
                                    Text(PasswordErrorMessage)
                                        .errorStyle()
                                }
                            }
                            
                            Spacer().frame(height: 35)
                            
                            Button(action: {
                                onEmailChecking()
                                onPasswordChecking()
//                                print(password)
                                self.endTextEditing()
                                
                                guard !isEmailError && !isPasswordError else {
                                    password = ""
                                    return
                                }
                                
                                service.sendAuthenticationRequestLab(username: email, password: password) { statusCode in
                                    handleAuthenticationResponse(statusCode: statusCode)
                                }
                            }){
                                ZStack() {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: 58)
                                        .background(Color.ButtonBlue)
                                        .cornerRadius(13)
                                    Text("login.Login".localized(localizationManager.language))
                                        .foregroundColor(.white)
                                        .titleWithoutBoldStyle()
                                }
                            }
                            
                            Spacer().frame(height: 25)
                            
//                            if self.service.isBiometricAvailable(){
//                                VStack {
//                                    if !KeychainStorage.hasCredentials(Account: "info") {
//                                        NavigationLink(destination: BiometricNotEnabledView()) {
//                                            biometricButton()
//                                        }
//                                    } else {
//                                        Button(action: {
////                                            self.service.bioAuthenticate(){result in
////                                                if result == 0 {
////                                                    // Token refresh and createBiometricLoginSession succeeded
////                                                }
////                                                else if result == -1 {             //Biometric record change
////                                                    currentState = .bioRecordChange
////                                                    self.service.disableBiometric()
////                                                }
////                                                else if result == -3 {   //token expired
////                                                    currentState = .bioRevoked
////                                                    self.service.disableBiometric()
////                                                }
////                                            }
//                                        }) {
//                                            biometricButton()
//                                        }
//                                    }
//                                    Spacer()
//                                }
////                                .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
//                            }
                            
                            Spacer().frame(height: 25)

//                            HStack(){
//                                NavigationLink(destination: RegistrationMainView(service: self.service.getRegistrationViewService())){
//                                    Text("login.Register".localized(localizationManager.language))
//                                        .foregroundColor(Color.ButtonBlue)
//                                        .contentStyle()
//                                }
//                                Spacer()
//                            }
//                            
//                            Spacer().frame(height: 9)
//                            
//                            HStack(){
//                                NavigationLink(destination: ForgotPasswordMainView(service: self.service.getForgotPasswordService())){
//                                    Text("login.ForgotPassword".localized(localizationManager.language))
//                                        .foregroundColor(Color.ButtonBlue)
//                                        .contentStyle()
//                                }
//                                Spacer()
//                            }
//                            Spacer().frame(height: 25)
                            
//                            HStack{
//                                GrayLineView()
//                                Spacer().frame(width: 5)
//                                Text("login.Or".localized(localizationManager.language))
//                                    .foregroundColor(.gray)
//                                    .titleWithoutBoldStyle()
//                                Spacer().frame(width: 5)
//                                GrayLineView()
//                            }
//                            //.customLeftRightPadding()
//                            
//                            Spacer().frame(height: 35)
//                            
//                            VStack{
//                                Button(action: {
////                                    self.service.getIamsmartService().genKeycloakBrokerRedirect()
//                                    //self.service.getIamsmartService().sendCodeToAuthEndpointLab()
//                                }){
//                                    ZStack() {
//                                        Rectangle()
//                                            .foregroundColor(.clear)
//                                            .frame(height: 58)
//                                            .background(Color.iamSmartGreen)
//                                            .cornerRadius(13)
//                                        HStack{
//                                            Image("Iamsmart")
//                                                .resizable()
//                                                .frame(width: 25, height: 33)
//                                                .foregroundColor(.white)
//                                            
//                                            Spacer().frame(width: 10)
//                                            
//                                            Text("login.iamSmart".localized(localizationManager.language))
//                                                .foregroundColor(.white)
//                                                .titleWithoutBoldStyle()
//                                        }
//                                    }
//                                }
//                                
//                                Button(action: {
//                                    openLinkInBrowser()
//                                }) {
//                                    Text("login.MoreInfo".localized(localizationManager.language))
//                                        .foregroundColor(Color.ButtonBlue)
//                                        .contentStyle()
//                                }
//                                
//                                Spacer()
//                            }
//                            //.customLeftRightPadding()
//                            
//                            Spacer().frame(width: 50)
                            
                            Spacer()
                            
                        }
                        .frame(maxHeight: .infinity)
                        
                    }

                    //.frame(height: 1000)

                    Spacer()
                    
                    Text("login.Enquiry".localized(localizationManager.language))
                        .contentStyle()
                    +
                    Text(": 8226 1886")
                        .contentStyle()
                }
                .customLeftRightPadding()

            }
            .onTapGesture(perform: {
                self.endTextEditing()
                //onPasswordChecking()
            })
            .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
                isEmailError = false
                isPasswordError = false
            })
            .navigationBarHidden(true)
        }
        .onOpenURL { url in
            print(url)
            if let code = url.queryDictionary?["code"] {
                print(code)
                self.service.getIamsmartService().sendCodeToAuthEndpoint(code: code)
            }
            if let state = url.queryDictionary?["state"] {
                print(state)
            }
        }
    }
    
    @ViewBuilder
    func biometricButton() -> some View {
        ZStack() {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 58)
                .background(Color(red: 0.31, green: 0.33, blue: 0.36))
                .cornerRadius(13)
            HStack {
                Image(systemName: self.service.getBiometricImage())
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
                Spacer().frame(width: 10)
                Text("login.BiometricNew.text1".localized(localizationManager.language))
                    .foregroundColor(.white)
                    .titleWithoutBoldStyle()
                +
                Text(self.service.getBiometricName())
                    .foregroundColor(.white)
                    .titleWithoutBoldStyle()
                +
                Text("login.BiometricNew.text2".localized(localizationManager.language))
                    .foregroundColor(.white)
                    .titleWithoutBoldStyle()
            }
        }
    }

    func onEmailChecking() {
        if(!email.isValidEmail)
        {
            isEmailError = true
            if email.isEmpty{
                EmailErrorMessage = "login.EmailError1".localized(localizationManager.language) //Please enter your email.
            }
            else {
                EmailErrorMessage = "login.EmailError2".localized(localizationManager.language)  //You have entered an invalid email address. Please try again.
            }
        }
        else{
            isEmailError = false
            EmailErrorMessage = ""
        }
    }
    
    func onPasswordChecking(){
        if(password.isEmpty)
        {
            isPasswordError = true
            PasswordErrorMessage = "login.PasswordError1".localized(localizationManager.language) //Please enter your password.
        }
        else{
            isPasswordError = false
            PasswordErrorMessage = ""
        }
    }
    
    func openLinkInBrowser(){
        
        var option = "en"
        let preferredLanguage = Locale.preferredLanguages.first ?? ""
        switch preferredLanguage {
        case "en":
            option = "en"
        case "zh-HK":
            option = "tc"
        case "zh-Hant":
            option = "tc"
        case "zh-Hans":
            option = "sc"
        default:
            option = "en"
        }

        guard let url = URL(string: "https://www.iamsmart.gov.hk/\(option)/") else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func handleAuthenticationResponse(statusCode: Int) {
        switch statusCode {
        case 200:
            currentState = .Verification
        case 401:
            isPasswordError = true
            PasswordErrorMessage = "login.PostError1".localized(localizationManager.language) //You have entered an invalid email address or incorrect password. Please try again.
            password = ""
        default:
            isPasswordError = true
            PasswordErrorMessage = "ServerErrorMessage".localized(localizationManager.language) //Failed to connect to the server. Please try again later.
            password = ""
        }
    }
    
}
