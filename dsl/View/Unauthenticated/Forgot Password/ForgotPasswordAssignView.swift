//
//  ForgotPasswordAssignView.swift
//  dsl
//
//  Created by chuang chin yuen on 16/2/2024.
//

import SwiftUI

struct ForgotPasswordAssignView: View {
    
    @ObservedObject var service: ForgotPasswordViewService
    
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var localizationManager: LocalizationManager

    @Binding var currentState: ForgotPasswordState
    
    @State private var newpassword = ""
    @State private var confirmPassword = ""
    
    @State private var showPasswordGuide: Bool = false

    @State private var isPasswordError: Bool = false
    @State private var isConfirmPasswordError: Bool = false
    
    @State private var passwordPostErrorMessage = ""
    
    @State private var isPostError: Bool = false
    @State private var postErrorMessage = ""

    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer().frame(height: 10)
                    
                    HStack{
                        BackButton(presentationMode: self.presentationMode)

                        Spacer()

                        Text("ForgotPassword.title".localized(localizationManager.language))
                            .titleStyle()

                        Spacer()

                        UnauthenticatedMenuButton()
                    }
                    .customLeftRightPadding()

                    Spacer().frame(height: 30)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        Spacer().frame(height: 40)
                        
                        VStack(alignment: .leading, spacing: 50){
                            Text("ForgotPassword.assign.text".localized(localizationManager.language))
                                .smallTitleStyle()
                            
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Text("ForgotPassword.assign.label1".localized(localizationManager.language))
                                        .foregroundColor(isPasswordError ? .red : .black)
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
                                
                                SecureInputView(inputTitleValue: "ForgotPassword.assign.placeholder1".localized(localizationManager.language), inputValue: $newpassword, color: isPasswordError ? .red: .gray, onChecking: onPasswordChecking, passwordEditChecking: true)
                                    .onChange(of: newpassword) { newValue in
                                        onPasswordChecking()
                                    }
                                
                                if isPasswordError && !passwordPostErrorMessage.isEmpty{
                                    Text(passwordPostErrorMessage)
                                        .errorStyle()
                                }
                                
//                                if isPasswordError {
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
                            
                            HStack{
                                
                                Spacer()
                                
                                Button(action: {
                                    onPasswordChecking()
                                    onConfirmPasswordChecking()
                                    self.endTextEditing()
                                    if !isPasswordError && !isConfirmPasswordError{
                                        self.service.assignPassword(password: newpassword){statuscode in
                                            if statuscode >= 200 && statuscode <= 299{
                                                currentState = .success
                                            }
                                            else if statuscode == 400{
                                                isPostError = true
                                                postErrorMessage = "ForgotPassword.assign.post.error1".localized(localizationManager.language)
                                            }
                                            else{
                                                isPasswordError = true
                                                passwordPostErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
                                            }
                                        }
                                    }
                                }){
                                    ZStack() {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 80, height: 40)
                                            .background(Color.ButtonBlue)
                                            .cornerRadius(4)
                                        Text("Twostepver.button1".localized(localizationManager.language))//.localized(localizationManager.language))
                                            .foregroundColor(.white)
                                            .contentStyle()
                                    }
                                }
                                
                            }
                        }
                        .customLeftRightPadding()
                    }

                    Spacer()
                }

            }
            .onTapGesture(perform: {
                self.endTextEditing()
            })
            .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
                isPasswordError = false
                isConfirmPasswordError = false
                isPostError = false
                passwordPostErrorMessage = ""
            })
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    func onPasswordChecking(){
        if(!newpassword.isValidPassword())
        {
            isPasswordError = true
            //passwordErrorMessage = "Invalid Password"
        }
        else{
            isPasswordError = false
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
//    ForgotPasswordAssignView()
//}
