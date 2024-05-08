//
//  LinkupUsernameView.swift
//  dsl
//
//  Created by chuang chin yuen on 27/2/2024.
//

import SwiftUI

struct LinkupUsernameView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @ObservedObject var linkUpService: LinkUpService
    
    @Binding var currentState: LinkUpState

    @State private var isEmailError: Bool = false
    @State private var EmailErrorMessage: String = ""
    
    @State private var isPasswordError: Bool = false
    @State private var PasswordErrorMessage: String = ""
    
    @State private var isPasswordEditing: Bool = false

    @Binding var email : String
    @Binding var password : String

    var body: some View {
        
        ScrollView(.vertical,showsIndicators: false){
            
            VStack(alignment: .leading){
                
                Text("LinkUp.linkedup.text1".localized(localizationManager.language))
                    .contentStyle()
                    .multilineTextAlignment(.leading)
                
                Spacer().frame(height: 30)
                
                Text("Register.Label1".localized(localizationManager.language))
                    .foregroundColor(isEmailError ? .red : .black)
                    .contentStyle()
                
                TextField("Register.Placeholder1".localized(localizationManager.language), text: $email, onEditingChanged: { isEditing in
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
                
                Spacer().frame(height: 30)
                
                Text("Register.Label2".localized(localizationManager.language))
                    .foregroundColor(isPasswordError ? .red : .black)
                    .contentStyle()
                
                SecureInputNoEyesView(inputTitleValue: "Register.Placeholder2".localized(localizationManager.language),inputValue: $password, color: isPasswordError ? .red: .gray, onChecking: onPasswordChecking)
//                    .onChange(of: password) { newValue in
//                        onPasswordChecking()
//                    }
                
                if isPasswordError {
                    Text(PasswordErrorMessage)
                        .errorStyle()
                }
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    onEmailChecking()
                    onPasswordChecking()
                    self.endTextEditing()
                    
                    guard !isEmailError && !isPasswordError else {
                        password = ""
                        return
                    }
                    linkUpService.linkUpAuth(username: email, password: password) { statusCode in
                        //print(statusCode)
                        handleAuthenticationResponse(statusCode: statusCode)
                    }
                    
                }){
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 58)
                            .background(Color.ButtonBlue)
                            .cornerRadius(4)
                        Text("login.Login".localized(localizationManager.language))
                            .foregroundColor(.white)
                            .titleWithoutBoldStyle()
                    }
                }
                
            }
        }
        .onTapGesture(perform: {
            self.endTextEditing()
        })
        .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
            isPasswordError = false
            isEmailError = false
        })

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
    
    func handleAuthenticationResponse(statusCode: Int) {
        switch statusCode {
        case 200:
            currentState = .LinkUpVerification
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

//#Preview {
//    LinkupUsernameView()
//}
