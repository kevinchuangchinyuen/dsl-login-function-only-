//
//  ForgotPasswordSMSVerView.swift
//  dsl
//
//  Created by chuang chin yuen on 16/2/2024.
//

import SwiftUI

struct ForgotPasswordSMSVerView: View {
    
    @ObservedObject var service: ForgotPasswordViewService

    @EnvironmentObject var localizationManager: LocalizationManager

    //@Binding var name : String
    @State private var code = ""
    @State private var resendTimer: Timer?
        
    @State private var RemainingTime: Int = 30

    @State private var ResendEnabled: Bool = true
    
    @State private var isCodeError: Bool = false
    
    @State private var codeErrorMessage = ""
    
    @Binding var currentState: ForgotPasswordState

    @Environment(\.presentationMode) private var presentationMode

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
                        
                        VStack(alignment: .leading){
                            Text("ForgotPassword.smsver.text1".localized(localizationManager.language))
                                .smallTitleStyle()
                            
                            Spacer().frame(height: 20)
                            
                            Text("ForgotPassword.smsver.text2".localized(localizationManager.language)
                                 + " \(self.service.mobile)"
                            )
                            .contentStyle()
                            
                            Spacer().frame(height: 20)
                            
                            Text("Twostepver.label2".localized(localizationManager.language))
                                .contentStyle()
                            
                            Spacer().frame(height: 0)
                            
                            VStack(alignment: .leading){
                                HStack{
                                    Text("\(self.service.smsOtpPrefix)-")
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
                                        self.service.verifyOtp(type: 2, enterOtp: code){statuscode in
                                            if statuscode == 200{
                                                currentState = .assign
                                            }
                                            else if statuscode == 400{
                                                isCodeError = true
                                                codeErrorMessage = "Twostepver.post.error1".localized(localizationManager.language)
                                            }
                                            else if statuscode == 401{
                                                isCodeError = true
                                                codeErrorMessage = "Twostepver.post.error2".localized(localizationManager.language)
                                            }
                                            else{
                                                isCodeError = true
                                                codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
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
                            
                            GrayLineView()
                            
                            HStack{
                                if ResendEnabled{
                                    Text("Twostepver.resend.text3".localized(localizationManager.language))
                                        .foregroundColor(.black)
                                        .contentStyle()
                                }
                                
                                Button(action: {
                                    code = ""
                                    sendSMSOtp()
                                    //startSMSResendTimer()
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
            //sendSMSOtp()
            startSMSResendTimer()
        }
        .onDisappear {
            stopSMSResendTimer()
        }
        .navigationBarHidden(true)

    }
    
    func startSMSResendTimer() {
        ResendEnabled = false
        RemainingTime = 30
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if RemainingTime > 0 {
                RemainingTime -= 1
            } else {
                stopSMSResendTimer()
            }
        }
        RunLoop.current.add(resendTimer!, forMode: .common)
    }
        
    func stopSMSResendTimer() {
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
    
    func sendSMSOtp(){
        self.service.sendSMSOtp(){statusCode in
            if statusCode == 200{
                isCodeError = false
                startSMSResendTimer()
            }
            else{
                isCodeError = true
                codeErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }
    }


}

//#Preview {
//    ForgotPasswordSMSVerView()
//}
