//
//  ChangePasswordNotAllowedLandingView.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import SwiftUI

struct ChangePasswordNotAllowLandingView: View {
    
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
                        Spacer().frame(width: 30, height: 30)

                        Spacer()
                        
                        Text("ChangePassword.title".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    
                    Spacer().frame(height: 70)
                    
                    VStack(alignment: .leading){
                        
                        Text("ChangePassword.notallow.text1".localized(localizationManager.language))
                            .contentStyle()
                        
                        Text("\n")
                            .contentStyle()
                        
                        Text("ChangePassword.notallow.text2".localized(localizationManager.language))
                            .contentStyle()
                    }

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
//    ChangePasswordNotAllowLandingView()
//}
