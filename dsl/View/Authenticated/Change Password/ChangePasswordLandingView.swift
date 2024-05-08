//
//  ChangePasswordLandingView.swift
//  dsl
//
//  Created by chuang chin yuen on 27/2/2024.
//

import SwiftUI

struct ChangePasswordLandingView: View {
    
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
//    ChangePasswordLandingView()
//}
