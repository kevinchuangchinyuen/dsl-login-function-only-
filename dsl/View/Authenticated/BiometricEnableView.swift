//
//  BiometricEnableView.swift
//  dsl
//
//  Created by chuang chin yuen on 14/2/2024.
//

import SwiftUI

struct BiometricEnableView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    @Binding var currentState: AuthenticatedState
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isShowingConfirmation = false
    
    var body: some View{
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack{
                    
                    Spacer().frame(height: 10)
                    
                    HStack{
                        HeaderView()
                        Spacer()
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 100)
                    
                    Text("BiometricEnable.text1".localized(localizationManager.language))
                        .titleStyle()
                    
                    Spacer().frame(height: 50)
                    
                    Image(systemName: "\(self.service.getBiometricImage())")
                        .resizable()
                        .frame(width: 100 ,height: 100)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        isShowingConfirmation = true
//                        self.service.enableBiometric { success in
//                            DispatchQueue.main.async {
//                                if success {
//                                    self.currentState = .Home
//                                }
//                            }
//                        }
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("BiometricEnable.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .alert("BiometricEnable.warning.title".localized(localizationManager.language), isPresented: $isShowingConfirmation) {
                        Button("BiometricEnable.warning.cancel".localized(localizationManager.language), role: .none) {
                            // nothing needed here
                        }//
                        Button("BiometricEnable.warning.confirm".localized(localizationManager.language), role: .none) {
                            self.service.enableBiometric { success in
                                DispatchQueue.main.async {
                                    if success {
                                        self.currentState = .Home
                                    }
                                }
                            }
                        }
                    } message: {
                        Text("BiometricEnable.warning.text".localized(localizationManager.language))
                    }
//                    .alert("Biometric enrollment", isPresented: $isShowingConfirmation) {
//                        Button {
//                            // nothing needed here
//                        } label: {
//                            Text("Cancel")
//                        }
//                        Button {
//                            self.service.enableBiometric { success in
//                                DispatchQueue.main.async {
//                                    if success {
//                                        self.currentState = .Home
//                                    }
//                                }
//                            }
//                        } label: {
//                            Text("Confirm")
//                        }
//                    } message: {
//                        Text("Old device biometric enrollment will be revoked if biometric enrollment is completed on this device. Are you sure?")
//                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 15)

                    Button(action: {
                        self.currentState = .Home
                    }){
                        Text("BiometricEnable.button2".localized(localizationManager.language))
                            .foregroundColor(.black)
                            .titleWithoutBoldStyle()
                    }
                    .customLeftRightPadding()

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

//#Preview {
//    BiometricEnableView()
//}
//
