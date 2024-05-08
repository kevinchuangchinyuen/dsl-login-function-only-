//
//  LinkUpVerificationView.swift
//  dsl
//
//  Created by chuang chin yuen on 4/3/2024.
//

import SwiftUI

struct LinkUpVerificationView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Binding var name : String
    @Binding var password : String
    @State private var code = ""
    @State private var resendTimer: Timer?
    
    @Binding var currentState: LinkUpState
    
    @ObservedObject var service: LinkUpService
    
    @State private var RemainingTime: Int = 30
    
    @State private var ResendEnabled: Bool = true
    
    @State private var isCodeError: Bool = false
    
    @State private var codeErrorMessage = ""
    
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            
            VStack(alignment: .leading){
                
                if self.service.type == "email" {
                    Text("ForgotPassword.emailver.text1".localized(localizationManager.language))
                        .titleStyle()
                }
                else if self.service.type == "sms"{
                    Text("ForgotPassword.smsver.text1".localized(localizationManager.language))
                        .titleStyle()
                }
                
//                Text("Twostepver.text1".localized(localizationManager.language))
//                    .titleStyle()
                
                Spacer().frame(height: 20)
                
                if self.service.type == "email" {
                    Text("Twostepver.text2".localized(localizationManager.language) + " \(name)")
                        .contentStyle()
                } else if self.service.type == "sms" {
                    Text("Twostepver.text3".localized(localizationManager.language) + " \(self.service.mobileNumber)")
                        .contentStyle()
                }
                
                Spacer().frame(height: 20)
                
                if self.service.type == "email" {
                    Text("Twostepver.label1".localized(localizationManager.language))
                        .contentStyle()
                } else if self.service.type == "sms" {
                    Text("Twostepver.label2".localized(localizationManager.language))
                        .contentStyle()
                }
                
                Spacer().frame(height: 0)
                
                VStack(alignment: .leading){
                    HStack{
                        Text("\(self.service.prefix)-")
                            .contentStyle()
                        
                        TextField("" , text: $code, onEditingChanged: { isEditing in
                            if !isEditing {
                                onCodeChecking()
                            }
                        })
                        .customLoginField(color: isCodeError ? .red: .gray)
                        //                                    .textFieldStyle(.roundedBorder)
                        //                                    .autocapitalization(.none)
                        //                                    .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                    }
                    
                    if isCodeError{
                        Text(codeErrorMessage)
                            .errorStyle()
                    }
                }
                
                Spacer().frame(height: 20)
                
                HStack{
                    
                    Spacer()
                    
                    Button(action: {
                        onCodeChecking()
                        self.endTextEditing()
                        
                        if !isCodeError {
                            self.service.verifyOtp(username: name, enterOtp: code) { statusCode in
                                if statusCode == 200 {
                                    currentState = .LinkUpConfirm
                                }
                                else {
                                    code = ""
                                    isCodeError = true
                                    
                                    if statusCode == 400 {
                                        codeErrorMessage = "Twostepver.post.error1".localized(localizationManager.language)
                                    }
                                    else if statusCode == 401{
                                        codeErrorMessage = "Twostepver.post.error2".localized(localizationManager.language)
                                    }
                                    else {
                                        codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
                                    }
                                    
                                    return
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
                            Text("Twostepver.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .contentStyle()
                        }
                    }
                }
                
                GrayLineView()
                
                HStack{
                    if ResendEnabled{
                        Text("Twostepver.resend.text3".localized(localizationManager.language))
                            .foregroundColor(.black)
                            .contentStyle()
                    }
                    
                    Button(action: {
                        code = ""
                        sendOtp()
                        startResendTimer()
                    }){
                        VStack() {
                            if !ResendEnabled {
                                Text("Twostepver.resend.text1".localized(localizationManager.language) + " \(RemainingTime) " + "Twostepver.resend.text2".localized(localizationManager.language))
                                    .foregroundColor(.gray)
                                    .contentStyle()
                                    .multilineTextAlignment(.leading)
                            }
                            else{
                                Text("Twostepver.resend.text4".localized(localizationManager.language))
                                    .foregroundColor(Color.ButtonBlue)
                                    .contentStyle()
                            }
                        }
                    }
                    .disabled(!ResendEnabled)
                    
                    Spacer()
                }
                
            }
        }
        .onTapGesture(perform: {
            self.endTextEditing()
        })
        .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
            isCodeError = false
        })
        .onAppear {
            if ResendEnabled && RemainingTime > 0 {
                startResendTimer()
            }
        }
//        .onDisappear {
//            stopResendTimer()
//        }
    }
    
    func startResendTimer() {
        ResendEnabled = false
        RemainingTime = 30

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if RemainingTime > 0 {
                RemainingTime -= 1
            } else {
                stopResendTimer()
            }
        }

        // Add the timer to the current run loop in the common mode
        RunLoop.current.add(resendTimer!, forMode: .common)
    }
        
    func stopResendTimer() {
        resendTimer?.invalidate()
        resendTimer = nil
        ResendEnabled = true
    }
    
    func onCodeChecking(){
        if(code.isEmpty)
        {
            isCodeError = true
            codeErrorMessage = "Twostepver.pre.error".localized(localizationManager.language)
        }
        else{
            isCodeError = false
            codeErrorMessage = ""
        }
    }
    
    func sendOtp(){
        
        self.service.linkUpAuth(username: name, password: password) { statusCode in
            //print(statusCode)
            if statusCode == 200{
                //currentState = .LinkUpVerification
            }
            else{
                isCodeError = true
                codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }
//        if(self.service.type == "sms"){
//            self.service.sendSMSOtp(mobileNumber: self.service.mobileNumber){statusCode in
//                if statusCode == 200{
//                    isCodeError = false
//                }
//                else{
//                    isCodeError = true
//                    codeErrorMessage = "ServerErrorMessage"
//                }
//            }
//        }
//        else if(self.service.type == "email"){
//            self.service.sendEmailOtp(email: name){statusCode in
//                if statusCode == 200{
//                    isCodeError = false
//                }
//                else{
//                    isCodeError = true
//                    codeErrorMessage = "ServerErrorMessage"
//                }
//            }
//        }
    }
}
