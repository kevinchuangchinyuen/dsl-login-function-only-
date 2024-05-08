//
//  ChangePasswordSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 23/2/2024.
//

import SwiftUI

struct ChangePasswordSuccessView: View {
    @ObservedObject var service: AuthenticatedViewService

    @Binding var currentState: AuthenticatedState
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
//        NavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
                        Spacer().frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Text("ChangePassword.title".localized(localizationManager.language))//.localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: self.$currentState)
                    }
                    
                    Spacer().frame(height: 100)
                    
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Spacer().frame(height: 100)
                    
                    Text("ChangePassword.success.text".localized(localizationManager.language))//.localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .customLeftRightPadding()

            }
//            .navigationBarHidden(true)
//        }
//        .navigationBarHidden(true)
    }
}

//#Preview {
//    ChangePasswordSuccessView()
//}
