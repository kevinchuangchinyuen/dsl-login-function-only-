//
//  ForgotPasswordMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 16/2/2024.
//

import SwiftUI

enum ForgotPasswordState{
    case landing
    case emailVer
    case smsVer
    case assign
    case success
}

struct ForgotPasswordMainView: View {
    
    @State private var currentState: ForgotPasswordState = .landing
    
    @ObservedObject var service: ForgotPasswordViewService

    var body: some View {
        viewForState(currentState)
    }
    
    @ViewBuilder
    private func viewForState(_ state: ForgotPasswordState) -> some View {
        switch state {
        case .landing:
            ForgotPasswordLandingView(service: self.service, currentState: $currentState)
        case .emailVer:
            ForgotPasswordEmailVerView(service: self.service, currentState: $currentState)
        case .smsVer:
            ForgotPasswordSMSVerView(service: self.service, currentState: $currentState)
        case .assign:
            ForgotPasswordAssignView(service: self.service, currentState: $currentState)
        case .success:
            ForgotPasswordSuccessView()
        }
    }

}

//#Preview {
//    ForgotPasswordMainView()
//}
