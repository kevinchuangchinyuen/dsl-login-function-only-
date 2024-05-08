//
//  SettingView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/1/2024.
//

import SwiftUI

struct UnauthenticatedSettingView: View {
    
    //private let state: ApplicationStateManager

    @EnvironmentObject var localizationManager: LocalizationManager

    @State private var email = ""
    
    @State private var isEng = false
    @State private var isTC = false
    @State private var isSC = false

    @State private var selectedOption = 0
    let options = ["English", "繁體中文", "简体中文"]
    var presentationModeMenu: Binding<PresentationMode>
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(presentationMode: Binding<PresentationMode>) {
        presentationModeMenu = presentationMode
        //self.state = state
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        BackButton(presentationMode: self.presentationMode)
                        
                        Spacer()
                        
                        Text("Setting".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 90)
                                        
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Setting.Languagetoused".localized(localizationManager.language))
                            .smallTitleStyle()

                        HStack(spacing: 12) {
                            Image(systemName: isEng ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isEng ? Color.ButtonBlue : .black)
                                .foregroundColor(isEng ? Color.ButtonBlue : .black)
                            
                            Text("English")
                                .contentStyle()
                            
                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .English
                            isEng = true
                            isTC = false
                            isSC = false
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: isTC ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isTC ? Color.ButtonBlue : .black)
                            
                            Text("繁體中文")
                                .contentStyle()

                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .TradChinese
                            isEng = false
                            isTC = true
                            isSC = false
                        }

                        
                        HStack(spacing: 12) {
                            Image(systemName: isSC ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isSC ? Color.ButtonBlue : .black)
                            
                            Text("简体中文")
                                .contentStyle()

                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .SimChinese
                            isEng = false
                            isTC = false
                            isSC = true
                        }
                                                                    
                        Spacer()
                    }
                    .customLeftRightPadding2()
                    
                    Spacer().frame(height: 15)

                }
                .navigationBarHidden(true)
            }
            .onAppear {
                let preferredLanguage = Locale.preferredLanguages.first ?? ""
                switch preferredLanguage {
                case "en":
                    isEng = true
                case "zh-HK":
                    isTC = true
                case "zh-Hant":
                    isTC = true
                case "zh-Hans":
                    isSC = true
                default:
                    isEng = true
                }
            }
        }
        .navigationBarHidden(true)
    }
        
}

struct AuthenticatedSettingView: View {
    
    //private let state: ApplicationStateManager
    @ObservedObject var service: AuthenticatedViewService

    @EnvironmentObject var localizationManager: LocalizationManager

    //@State var isBiometricEnabled = false
    
    @State var isBiometricEnabled = KeychainStorage.hasCredentials(Account: "info")
    
    @State private var isBiometricError = false

    @State private var BiometricTokenSub = ""
    
    @State private var biometricToggleInProgress = false

    @State private var isShowingConfirmation = false

    @State private var email = ""
    
    @State private var isEng = false
    @State private var isTC = false
    @State private var isSC = false

    @State private var selectedOption = 0
    let options = ["English", "繁體中文", "简体中文"]
    var presentationModeMenu: Binding<PresentationMode>
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(service: AuthenticatedViewService ,presentationMode: Binding<PresentationMode>) {
        self.service = service
        self.presentationModeMenu = presentationMode
//        self.isBiometricEnabled = self.checkBiometricSub()
//        self.isBiometricEnabled = KeychainStorage.hasCredentials()
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        BackButton(presentationMode: self.presentationMode)
                        
                        Spacer()
                        
                        Text("Setting".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 90)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Toggle(isOn: Binding<Bool>(
                                get: { self.service.biometricEnabled },
                                set: { self.service.biometricEnabled = $0 }
                            ))
                            {
                                Text("Setting.BiometricAuthentication".localized(localizationManager.language))
                                    .smallTitleStyle()
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.ButtonBlue))
                            .disabled(self.service.biometricError || !self.service.isBiometricAvailable())
                            .onChange(of: self.service.biometricEnabled) { isEnabled in
                                if isEnabled && !biometricToggleInProgress {
                                    isShowingConfirmation = true
                                    //                                    self.service.enableBiometric { success in
                                    //                                        DispatchQueue.main.async {
                                    //                                            if !success {
                                    //                                                // Update UI to reflect that biometric is not enabled.
                                    //                                                self.service.biometricEnabled = false
                                    //                                                biometricToggleInProgress = true
                                    //                                            }
                                    //                                        }
                                    //                                    }
                                } else if !isEnabled && !biometricToggleInProgress {
                                    self.service.disableBiometric { success in
                                        DispatchQueue.main.async {
                                            if !success {
                                                // Update UI to reflect that biometric is enabled.
                                                self.service.biometricEnabled = true
                                                biometricToggleInProgress = true
                                            }
                                        }
                                    }
                                }
                                else if(biometricToggleInProgress){
                                    biometricToggleInProgress = false
                                }
                            }
                            .alert("BiometricEnable.warning.title".localized(localizationManager.language), isPresented: $isShowingConfirmation) {
                                Button("BiometricEnable.warning.cancel".localized(localizationManager.language), role: .none) {
                                    self.service.biometricEnabled = false
                                    biometricToggleInProgress = true
                                }
                                Button("BiometricEnable.warning.confirm".localized(localizationManager.language), role: .none) {
                                    self.service.enableBiometric { success in
                                        DispatchQueue.main.async {
                                            if !success {
                                                self.service.biometricEnabled = false
                                                biometricToggleInProgress = true
                                            }
                                        }
                                    }
                                }
                            } message: {
                                Text("BiometricEnable.warning.text".localized(localizationManager.language))
                            }
                            
                        }
                        if self.service.biometricError {
                            Text("Setting.BiometricAuthenticationNotAllow.text".localized(localizationManager.language))
                                .errorStyle()
                        }
                    }
                    .customLeftRightPadding2()
                    
                    Spacer().frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Setting.Languagetoused".localized(localizationManager.language))
                            .smallTitleStyle()

                        HStack(spacing: 12) {
                            Image(systemName: isEng ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isEng ? Color.ButtonBlue : .black)
                                .foregroundColor(isEng ? Color.ButtonBlue : .black)
                            
                            Text("English")
                                .contentStyle()
                            
                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .English
                            isEng = true
                            isTC = false
                            isSC = false
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: isTC ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isTC ? Color.ButtonBlue : .black)
                            
                            Text("繁體中文")
                                .contentStyle()

                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .TradChinese
                            isEng = false
                            isTC = true
                            isSC = false
                        }

                        HStack(spacing: 12) {
                            Image(systemName: isSC ? "circle.fill" : "circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(isSC ? Color.ButtonBlue : .black)
                            
                            Text("简体中文")
                                .contentStyle()

                            Spacer()
                        }
                        .onTapGesture {
                            localizationManager.language = .SimChinese
                            isEng = false
                            isTC = false
                            isSC = true
                        }
                                                                    
                        Spacer()
                    }
//                    .padding(EdgeInsets(top: 0, leading: 35, bottom: 15, trailing: 35))
                    .customLeftRightPadding2()
                    
                    Spacer().frame(height: 15)

                }
                .navigationBarHidden(true)
            }
            .onAppear {
                let preferredLanguage = Locale.preferredLanguages.first ?? ""
                switch preferredLanguage {
                case "en":
                    isEng = true
                case "zh-HK":
                    isTC = true
                case "zh-Hant":
                    isTC = true
                case "zh-Hans":
                    isSC = true
                default:
                    isEng = true
                }
                //self.isBiometricEnabled = self.checkBiometricSub()
            }
        }
        .navigationBarHidden(true)
    }
    
    func checkBiometricSub() -> Bool{
        if(KeychainStorage.hasCredentials(Account: "info")){
            if(KeychainStorage.decodeSub() == self.service.rfTokenClaims?.sub){
                return true
            }
            else{
                isBiometricError = true
                return false
            }
        }
        else{
            return false
        }
    }
    
}

