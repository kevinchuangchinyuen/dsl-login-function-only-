//
//  DeleteLandingView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/2/2024.
//

import SwiftUI

struct DeleteLandingView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState
    
    @Binding var deletecurrentState: DeleteAccountState
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
//        CustomNavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        Spacer().frame(width: 30, height: 30)

                        Spacer()
                        
                        Text("DeleteAccount.title".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    
                    Spacer().frame(height: 70)
                    
                    VStack(alignment: .leading){
                        Text("DeleteAccount.landing.text".localized(localizationManager.language))
                            .contentStyle()
                    }

                    Spacer().frame(height: 70)
                    
                    Button(action: {
                        deletecurrentState = .Confirm
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("DeleteAccount.landing.button".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
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
//    DeleteLandingView()
//}
