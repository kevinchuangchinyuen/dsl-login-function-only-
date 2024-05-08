//
//  FirstTimeLoginVerificationView.swift
//  dsl
//
//  Created by chuang chin yuen on 8/3/2024.
//

import SwiftUI

struct FirstTimeLoginVerificationView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Binding var name : String
    @Binding var password : String
    @State private var code = ""
    @State private var resendTimer: Timer?
    
    @Binding var currentState: LinkUpState
    
    @ObservedObject var linkUpService: LinkUpService
    
    @ObservedObject var service: AuthenticatedViewService
    
    @State private var RemainingTime: Int = 30
    
    @State private var ResendEnabled: Bool = true
    
    @State private var isCodeError: Bool = false
    
    @State private var codeErrorMessage = ""
    
    var body: some View {
        
        ScrollView(.vertical,showsIndicators: false){
                        
            VStack(alignment: .leading){
                Text("Twostepver.text1".localized(localizationManager.language))
                    .titleStyle()
                
                Spacer().frame(height: 20)
                
                if self.linkUpService.type == "email" {
                    Text("Twostepver.text2".localized(localizationManager.language) + " \(name)")
                        .contentStyle()
                } else if self.linkUpService.type == "sms" {
                    Text("Twostepver.text3".localized(localizationManager.language) + " \(self.linkUpService.mobileNumber)")
                        .contentStyle()
                }
                
                Spacer().frame(height: 20)
                
                if self.linkUpService.type == "email" {
                    Text("Twostepver.label1".localized(localizationManager.language))
                        .contentStyle()
                } else if self.linkUpService.type == "sms" {
                    Text("Twostepver.label2".localized(localizationManager.language))
                        .contentStyle()
                }
                
                Spacer().frame(height: 0)
                
                VStack(alignment: .leading){
                    HStack{
                        Text("\(self.linkUpService.prefix)-")
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
                            self.linkUpService.verifyOtp(username: name, enterOtp: code) { statusCode in
                                if statusCode == 200 {
                                    self.linkUpService.linkUp(username: name, password: password, iamSmartAccountSub: self.service.idTokenClaims!.sub, iamSmartAccountToken: self.service.idToken, isFirstTimeLink: true) { success in
                                        if success {
                                            currentState = .LinkUpSuccess
                                        }
                                    }
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
        self.linkUpService.linkUpAuth(username: name, password: password) { statusCode in
            //print(statusCode)
            if statusCode == 200{
                //currentState = .LinkUpVerification
            }
            else{
                isCodeError = true
                codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }

//        if(self.linkUpService.type == "sms"){
//            self.linkUpService.sendSMSOtp(mobileNumber: self.linkUpService.mobileNumber){statusCode in
//                if statusCode == 200{
//                    isCodeError = false
//                }
//                else{
//                    isCodeError = true
//                    codeErrorMessage = "ServerErrorMessage"
//                }
//            }
//        }
//        else if(self.linkUpService.type == "email"){
//            self.linkUpService.sendEmailOtp(email: name){statusCode in
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

//#Preview {
//    FirstTimeLoginVerificationView()
//}
