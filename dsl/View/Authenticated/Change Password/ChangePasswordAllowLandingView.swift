//
//  ChangePasswordAllowLandingView.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import SwiftUI

struct ChangePasswordAllowLandingView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState
        
    @ObservedObject var changePasswordService: ChangePasswordViewService
    
    @Binding var changePasswordState: ChangePasswordState

    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var haveOldPassword: Bool = true

    @State private var oldpassword = ""
    @State private var newpassword = ""
    @State private var confirmPassword = ""
    
    @State private var showPasswordGuide: Bool = false

    @State private var isOldPasswordError: Bool = false
    @State private var isNewPasswordError: Bool = false
    @State private var isConfirmPasswordError: Bool = false
    
    @State private var oldPasswordPostErrorMessage = ""
    @State private var newPasswordPostErrorMessage = ""
    
    @State private var isPostError: Bool = false
    @State private var postErrorMessage = ""


    var body: some View {
//        NavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        Spacer().frame(width: 30, height: 30)

                        Spacer()
                        
                        Text("ChangePassword.title".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    
                    Spacer().frame(height: 30)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        Spacer().frame(height: 40)
                        
                        VStack(alignment: .leading, spacing: 50){
                            
                            VStack(alignment: .leading){
                                
                                if haveOldPassword{
                                    Text("ChangePassword.allow.label1".localized(localizationManager.language))
                                        .foregroundColor(isOldPasswordError ? .red : .black)
                                        .contentStyle()
                                    + Text("*")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    
                                    SecureInputView(inputTitleValue: "ChangePassword.allow.placeholder1".localized(localizationManager.language), inputValue: $oldpassword, color: isOldPasswordError ? .red: .gray, onChecking: onOldPasswordChecking, passwordEditChecking: false)
                                    
                                    if isOldPasswordError{
                                        if(oldpassword.isEmpty){
                                            Text("ChangePassword.allow.pre.error1".localized(localizationManager.language))
                                                .errorStyle()
                                        }
                                        else{
                                            Text(oldPasswordPostErrorMessage)
                                                .errorStyle()
                                        }
                                    }
                                    
                                    Spacer().frame(height: 30)
                                }
                                
                                HStack{
                                    Text("ForgotPassword.assign.label1".localized(localizationManager.language))
                                        .foregroundColor(isNewPasswordError ? .red : .black)
                                        .contentStyle()
                                    + Text("*")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            showPasswordGuide.toggle()
                                        }
                                    Spacer()
                                }
                                
                                if(showPasswordGuide){
                                    Text("Register.password.tips".localized(localizationManager.language))
                                        .foregroundColor(.gray)
                                        .infoStyle()
                                }
                                
                                SecureInputView(inputTitleValue: "ForgotPassword.assign.placeholder1".localized(localizationManager.language), inputValue: $newpassword, color: isNewPasswordError ? .red: .gray, onChecking: onNewPasswordChecking, passwordEditChecking: true)
                                    .onChange(of: newpassword) { newValue in
                                        onNewPasswordChecking()
                                    }
                                
                                if isNewPasswordError && !newPasswordPostErrorMessage.isEmpty{
                                    Text(newPasswordPostErrorMessage)
                                        .errorStyle()
                                }
                                
//                                if isNewPasswordError {
//                                    if newpassword.isEmpty {
//                                        Text("ForgotPassword.assign.pre.error1".localized(localizationManager.language))
//                                            .errorStyle()
//                                    } else if newpassword.count < 8 {
//                                        Text("Register.password.pre.error2".localized(localizationManager.language))
//                                            .errorStyle()
//                                    } else if !newpassword.contains(where: { $0.isUppercase }) || !newpassword.contains(where: { $0.isLowercase }) {
//                                        Text("Register.password.pre.error3".localized(localizationManager.language))
//                                            .errorStyle()
//                                    } else if !newpassword.contains(where: \.isNumber) {
//                                        Text("Register.password.pre.error4".localized(localizationManager.language))
//                                            .errorStyle()
//                                    } else if !newpassword.contains(where: { !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }) {
//                                        Text("Register.password.pre.error5".localized(localizationManager.language))
//                                            .errorStyle()
//                                    }
//                                }
                                
                                Spacer().frame(height: 30)
                                
                                Text("ForgotPassword.assign.label2".localized(localizationManager.language))
                                    .foregroundColor(isConfirmPasswordError ? .red : .black)
                                    .contentStyle()
                                + Text("*")
                                    .foregroundColor(.red)
                                    .contentStyle()

                                SecureInputView(inputTitleValue: "ForgotPassword.assign.placeholder2".localized(localizationManager.language), inputValue: $confirmPassword, color: isConfirmPasswordError ? .red: .gray, onChecking: onConfirmPasswordChecking, passwordEditChecking: false)
                                
                                if isConfirmPasswordError{
                                    if(confirmPassword.isEmpty){
                                        Text("Register.confirmpassword.pre.error1".localized(localizationManager.language))
                                            .errorStyle()
                                    }
                                    else{
                                        Text("Register.confirmpassword.pre.error2".localized(localizationManager.language))
                                            .errorStyle()
                                    }
                                }
                                
                            }
                            
                            if isPostError {
                                Text(postErrorMessage)
                                    .errorStyle()
                            }

                            Button(action: {
                                if haveOldPassword{
                                    onOldPasswordChecking()
                                }
                                onNewPasswordChecking()
                                onConfirmPasswordChecking()
                                self.endTextEditing()
                                if !isOldPasswordError && !isNewPasswordError && !isConfirmPasswordError{
                                    //print("Change password ok")
                                    if haveOldPassword{
                                        self.changePasswordService.checkOldPassword(password: oldpassword){ statuscode in
                                            if statuscode >= 300 && statuscode <= 303 {  //oldpassword correct
                                                isOldPasswordError = false
                                                self.changePasswordService.ChangeNewPassword(password: newpassword){statuscode in
                                                    if statuscode >= 200 && statuscode <= 299{
                                                        changePasswordState = .Success   //success change password
                                                    }
                                                    else if statuscode == 400{ //password in history
                                                        isPostError = true
                                                        postErrorMessage = "ForgotPassword.assign.post.error1".localized(localizationManager.language)
                                                    }
                                                    else{
                                                        isNewPasswordError = true
                                                        newPasswordPostErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
                                                    }
                                                }
                                            }
                                            else if statuscode == 401{   //old password incorrect
                                                isOldPasswordError = true
                                                oldPasswordPostErrorMessage = "ChangePassword.allow.post.error1".localized(localizationManager.language)
                                            }
                                            else{
                                                isOldPasswordError = true
                                                oldPasswordPostErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
                                            }
                                        }
                                    }
                                    else{
                                        self.changePasswordService.ChangeNewPassword(password: newpassword){statuscode in
                                            if statuscode >= 200 && statuscode <= 299{
                                                changePasswordState = .Success   //success change password
                                            }
                                            else if statuscode == 400{ //password in history
                                                isNewPasswordError = true
                                                newPasswordPostErrorMessage = "ForgotPassword.assign.post.error1".localized(localizationManager.language)
                                            }
                                            else{
                                                isNewPasswordError = true
                                                newPasswordPostErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
                                            }
                                        }
                                    }
                                    
                                }
                            }){
                                ZStack() {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: 58)
                                        .background(Color.ButtonBlue)
                                        .cornerRadius(4)
                                    Text("ChangePassword.allow.button".localized(localizationManager.language))//.localized(localizationManager.language))
                                        .foregroundColor(.white)
                                        .titleWithoutBoldStyle()
                                }
                            }
                            
                        }
                        
                    }

                    Spacer()
                }
                .customLeftRightPadding()

            }
            .onTapGesture(perform: {
                self.endTextEditing()
            })
            //.navigationBarHidden(true)
        
        .onAppear(
            perform: {
                self.changePasswordService.checkHaveCredentials(){ haveCredentials in
                    if haveCredentials{
                        haveOldPassword = true
                    }
                    else{
                        haveOldPassword = false
                    }
                }
            }
        )
        .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
            isOldPasswordError = false
            isNewPasswordError = false
            isConfirmPasswordError = false
            isPostError = false
            oldPasswordPostErrorMessage = ""
            newPasswordPostErrorMessage = ""
        })
        //.navigationBarHidden(true)
    }
    
    func onOldPasswordChecking(){
        if(oldpassword.isEmpty)
        {
            isOldPasswordError = true
            //passwordErrorMessage = "Invalid Password"
        }
        else{
            isOldPasswordError = false
        }
    }

    func onNewPasswordChecking(){
        if(!newpassword.isValidPassword())
        {
            isNewPasswordError = true
            //passwordErrorMessage = "Invalid Password"
        }
        else{
            isNewPasswordError = false
        }
    }
    
    func onConfirmPasswordChecking(){
        if(newpassword==confirmPassword || newpassword.isEmpty)
        {
            isConfirmPasswordError = false
        }
        else{
            isConfirmPasswordError = true
        }
    }

}

//#Preview {
//    ChangePasswordAllowLandingView()
//}
