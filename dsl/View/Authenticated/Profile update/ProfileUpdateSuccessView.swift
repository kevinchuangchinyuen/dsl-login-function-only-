//
//  ProfileUpdateSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 21/2/2024.
//

import SwiftUI

struct ProfileUpdateSuccessView: View {
    
    @ObservedObject var authservice: AuthenticatedViewService

    @Binding var authcurrentState: AuthenticatedState
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        
        NavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
                        Spacer().frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Text("ProfileUpdate.title".localized(localizationManager.language))//.localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.authservice, currentState: self.$authcurrentState)
                    }
                    
                    Spacer().frame(height: 100)
                    
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Spacer().frame(height: 100)
                    
                    Text("ProfileUpdate.success.text".localized(localizationManager.language))//.localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .customLeftRightPadding()

            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    ProfileUpdateSuccessView()
//}
