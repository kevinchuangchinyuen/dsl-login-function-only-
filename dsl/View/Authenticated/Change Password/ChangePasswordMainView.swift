//
//  ChangePasswordMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import SwiftUI

enum ChangePasswordState{
    case Landing
    case NotAllowLanding
    case AllowLanding
    case Success
}

struct ChangePasswordMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState

    @ObservedObject var changePasswordService: ChangePasswordViewService

    @State private var changePasswordcurrentState: ChangePasswordState = .Landing

    var body: some View {
        NavigationView(){
            viewForState(changePasswordcurrentState)
                .navigationBarHidden(true)
        }
        .onAppear(
            perform: {
                self.changePasswordService.checkEmail(){ haveEmail in
                    if haveEmail{
                        changePasswordcurrentState = .AllowLanding
                    }
                    else{
                        changePasswordcurrentState = .NotAllowLanding
                    }
                }
            }
        )
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func viewForState(_ state: ChangePasswordState) -> some View {
        switch state {
        case .Landing:
            ChangePasswordLandingView(service: self.service, currentState: self.$currentState)
        case .NotAllowLanding:
            ChangePasswordNotAllowLandingView(service: self.service, currentState: self.$currentState)
        case .AllowLanding:
            ChangePasswordAllowLandingView(service: self.service, currentState: self.$currentState, changePasswordService: self.changePasswordService, changePasswordState: self.$changePasswordcurrentState)
        case .Success:
            ChangePasswordSuccessView(service: self.service, currentState: self.$currentState)
        }
    }

}

//#Preview {
//    ChangePasswordMainView()
//}
