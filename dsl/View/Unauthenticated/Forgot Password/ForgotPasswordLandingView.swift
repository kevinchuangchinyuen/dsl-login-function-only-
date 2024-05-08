//
//  ForgotPasswordView.swift
//  dsl
//
//  Created by chuang chin yuen on 18/1/2024.
//

import SwiftUI

struct ForgotPasswordLandingView: View {
    
    @State private var email = ""
    //@Environment(\.dismiss) private var dismiss
    
    @State private var isEmailError: Bool = false
    
    @State private var EmailErrorMessage: String = ""
    
    @ObservedObject var service: ForgotPasswordViewService

    @EnvironmentObject var localizationManager: LocalizationManager

    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var currentState: ForgotPasswordState
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack{
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
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
                        
                        HStack{
                            Text("ForgotPassword.landing.text".localized(localizationManager.language))
                                .smallTitleStyle()
                            Spacer()
                        }
                        .customLeftRightPadding()
                        
                        Spacer().frame(height: 50)
                        
                        VStack(alignment: .leading){
                            Text("ForgotPassword.landing.label".localized(localizationManager.language))
                                .foregroundColor(isEmailError ? .red : .black)
                                .contentStyle()
                            
                            TextField("Register.Placeholder1".localized(localizationManager.language), text: $email, onEditingChanged: { isEditing in
                                if !isEditing {
                                    onEmailChecking()
                                }
                            })
                            .customTextField(color: isEmailError ? .red: .gray)
                            .keyboardType(.emailAddress)
                            .onChange(of: email) { newValue in
                                onEmailChecking()
                            }
                            
                            if isEmailError{
                                Text(EmailErrorMessage)
                                    .errorStyle()
                            }
                        }
                        .customLeftRightPadding()
                        
                        Spacer().frame(height: 50)

                        Button(action: {
                            self.endTextEditing()
                            onEmailChecking()
//                            if !isEmailError{
//                                self.service.email = email
//                                self.service.sendEmailOtp(){statusCode in
//                                    if statusCode == 200{
//                                        //isCodeError = false
//                                    }
//                                    else{
//                                        //isCodeError = true
//                                        //codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
//                                    }
//                                    
//                                    //                                self.service.getUserByEmail(email: email){statusCode in
//                                    //                                    if statusCode == 200{
//                                    //                                        currentState = .emailVer
//                                    //                                        //                                    self.service.sendEmailOtp(){statusCode in
//                                    //                                        //                                        if statusCode == 200{
//                                    //                                        //                                            currentState = .emailVer
//                                    //                                        //                                        }
//                                    //                                        //                                        else{
//                                    //                                        //                                            EmailErrorMessage = "ServerErrorMessage"
//                                    //                                        //                                        }
//                                    //                                        //                                    }
//                                    //                                    }
//                                    //                                    else if statusCode == 404{
//                                    //                                        currentState = .emailVer
//                                    //                                    }
//                                    //                                    else{
//                                    //                                        EmailErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
//                                    //                                    }
//                                    //                                }
//                                    currentState = .emailVer
//                                }
//                            }
                        }){
                            ZStack() {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 58)
                                    .background(Color.ButtonBlue)
                                    .cornerRadius(4)
                                Text("ForgotPassword.landing.button".localized(localizationManager.language))
                                    .foregroundColor(.white)
                                    .titleWithoutBoldStyle()
                            }
                        }
                        .customLeftRightPadding()
                        
                    }
                    Spacer()
                }
            }
            .onTapGesture {
                self.endTextEditing()
            }
            .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
                isEmailError = false
            })
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    func onEmailChecking() {
        if(!email.isValidEmail)
        {
            isEmailError = true
            if email.isEmpty{
                EmailErrorMessage = "Register.email.pre.error3".localized(localizationManager.language)
            }
            else {
                EmailErrorMessage = "Register.email.pre.error1".localized(localizationManager.language)
            }
        }
        else{
            isEmailError = false
            EmailErrorMessage = ""
        }
    }

}

//#Preview {
//    ForgotPasswordLandingView()
//}
