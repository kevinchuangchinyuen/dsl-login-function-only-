//
//  LInkUpMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 27/2/2024.
//

import SwiftUI


enum LinkUpState{
    case Blank
    case NotIamSmartAcLanding
    case BiometricLinkUpLanding
    case UsernameLinkUpLanding
    case LinkUpVerification
    case LinkUpConfirm
    case LinkUpSuccess
    case AlreadyLinkUp
}

struct LinkUpMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService
        
    @Binding var currentState: AuthenticatedState

    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var linkupcurrentState: LinkUpState = .Blank
    
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
                        //BackButton(dismiss: self.dismiss)
                        Spacer().frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        if linkupcurrentState != .LinkUpConfirm{
                            Text("LinkUp.title".localized(localizationManager.language))
                                .titleStyle()
                        }
                        else{
                            Text("LinkUp.confirm.title")
                                .titleStyle()
                        }
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: self.$currentState)
                    }
                    
                    if linkupcurrentState != .LinkUpConfirm{
                        Spacer().frame(height: 70)
                    }
                    else{
                        Spacer().frame(height: 10)
                    }
                    
                    viewForState(linkupcurrentState)
                    
                    Spacer()
                }
                .customLeftRightPadding()
                
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .onAppear {
            if service.idTokenClaims!.authLevel == "3" || service.idTokenClaims!.authLevel == "4"{
//                if KeychainStorage.hasCredentials(Account: "info"){
//                    linkupcurrentState = .UsernameLinkUpLanding
//                }
//                else{
//                    linkupcurrentState = .UsernameLinkUpLanding
//                }
                self.service.getUserProfile(){success in
                    if success{
                        if let oldsub = self.service.userModel!.attributes.oldSub {
                            if oldsub[0].isEmpty{
                                linkupcurrentState = .UsernameLinkUpLanding
                            }
                            else{
                                linkupcurrentState = .AlreadyLinkUp
                            }
                        }
                        else{
                            linkupcurrentState = .UsernameLinkUpLanding
                        }
                    }
//                    else {
//                        linkupcurrentState = .UsernameLinkUpLanding
//                    }
                }
            }
            else{
                linkupcurrentState = .NotIamSmartAcLanding
            }
        }
    }
    
   // KeychainStorage.hasCredentials(Account: "info")
    
    @ViewBuilder
    private func viewForState(_ state: LinkUpState) -> some View {
        switch state {
        case .Blank:
            ZStack{
                
            }
        case .NotIamSmartAcLanding:
            LinkUpNotIamSmartView()
        case .BiometricLinkUpLanding:
            LinkupBiometricView(service: self.service)
        case .UsernameLinkUpLanding:
            LinkupUsernameView(linkUpService: self.service.getLinkUpService(), currentState: $linkupcurrentState,email: $name, password: $password)
        case .LinkUpVerification:
            LinkUpVerificationView(name: $name, password: $password,currentState: $linkupcurrentState ,service: self.service.getLinkUpService())
        case .LinkUpConfirm:
            LinkUpConfirmView(linkUpService: self.service.getLinkUpService(), service: self.service, currentState: $linkupcurrentState, username: $name, password: $password)
        case .LinkUpSuccess:
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.ButtonBlue)
            
            Spacer().frame(height: 70)
            
            Text("LinkUp.success.text2".localized(localizationManager.language))
                .titleStyle()
                .multilineTextAlignment(.center)
        case .AlreadyLinkUp:
            Text("LinkUp.havelinkedup.text".localized(localizationManager.language))
                .titleWithoutBoldStyle()
                .multilineTextAlignment(.leading)
        }
    }

}

//#Preview {
//    LinkUpMainView()
//}
