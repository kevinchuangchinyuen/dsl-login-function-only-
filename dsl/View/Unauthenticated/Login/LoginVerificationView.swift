//
//  LoginEmailVerificationView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import SwiftUI

struct LoginVerificationView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Binding var name : String
    @Binding var password : String
    @State private var code = ""
    @State private var resendTimer: Timer?
    
    @ObservedObject var service: UnauthenticatedViewService
    
    @State private var RemainingTime: Int = 30

    @State private var ResendEnabled: Bool = true
    
    @State private var isCodeError: Bool = false
    
    @State private var codeErrorMessage = ""

    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer().frame(height: 10)
                    
                    HStack{
                        HeaderView()
                        //Image("Header")
                        Spacer()
                        UnauthenticatedMenuButton()
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 15)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        
                        Spacer().frame(height: 25)
                        
                        VStack(alignment: .leading){
                            Text("Twostepver.text1".localized(localizationManager.language))
                                .titleStyle()
                            
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
                                        self.service.sendAuthenticationRequestWithOtp(username: name, password: password, otp: code) { statusCode in
                                            guard statusCode == 302 else {
                                                code = ""
                                                isCodeError = true
                                                
                                                if statusCode == 400 {
                                                    codeErrorMessage = "Twostepver.post.error1".localized(localizationManager.language)
                                                }
                                                else if statusCode == 401 {
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
                        .customLeftRightPadding()
                    }
                    
                    Spacer()
                }

            }
            .onTapGesture(perform: {
                self.endTextEditing()
            })
            .onChange(of: Locale.preferredLanguages.first, perform: {newValue in
                isCodeError = false
            })
            .navigationBarHidden(true)
        }
        .onAppear {
            startResendTimer()
        }
        .onDisappear {
            stopResendTimer()
        }
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
        service.sendAuthenticationRequestLab(username: name, password: password) { statusCode in
            if statusCode == 200{
                isCodeError = false
            }
            else{
                isCodeError = true
                codeErrorMessage = "ServerErrorMessage"
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

//#Preview {
//    LoginEmailVerificationView()
//}
