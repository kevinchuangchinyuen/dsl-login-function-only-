//
//  FirstTimeLoginLinkUpMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 8/3/2024.
//

import SwiftUI

//enum FirstTimeLinkUpState{
//    case Blank
//    case UsernameLinkUpLanding
//    case LinkUpVerification
//    case LinkUpSuccess
//}

struct FirstTimeLoginLinkUpMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService
        
    @Binding var currentState: AuthenticatedState

    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var linkupcurrentState: LinkUpState = .UsernameLinkUpLanding
    
    @State private var name = ""
    
    @State private var password = ""
    
    var body: some View {
        
        NavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        HeaderView()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: self.$currentState)
                    }
                    
                    Spacer().frame(height: 70)
                    
                    viewForState(linkupcurrentState)
                    
                    Spacer()
                }
                .customLeftRightPadding()
                
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func viewForState(_ state: LinkUpState) -> some View {
        switch state {
        case .Blank:
            ZStack{
                
            }
        case .NotIamSmartAcLanding:
            ZStack{
                
            }
        case .BiometricLinkUpLanding:
            ZStack{
                
            }
        case .UsernameLinkUpLanding:
            FirstTimeLoginUsernameView(currentState: $currentState, linkUpService: self.service.getLinkUpService(), linkUpCurrentState: $linkupcurrentState, email: $name, password: $password)
        case .LinkUpVerification:
            FirstTimeLoginVerificationView(name: $name, password: $password,currentState: $linkupcurrentState, linkUpService: self.service.getLinkUpService() ,service: self.service)
        case .LinkUpConfirm:
            ZStack{
                
            }
        case .LinkUpSuccess:
            FirstTimeLoginSuccessView(currentState: $currentState)
        case .AlreadyLinkUp:
            ZStack{
                
            }
        }
         
    }
    
}

//#Preview {
//    FirstTimeLoginLinkUpMainView()
//}
