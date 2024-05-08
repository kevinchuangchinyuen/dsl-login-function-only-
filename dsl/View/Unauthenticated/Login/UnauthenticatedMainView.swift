//
//  LoginMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import SwiftUI

enum LoginState{
    case bioRecordChange
    case Landing
    case Verification
    case bioRevoked
}

struct UnauthenticatedMainView: View {
    
    @ObservedObject var service: UnauthenticatedViewService

    @State private var name = ""
    
    @State private var password = ""

    @State private var currentState: LoginState = .Landing
    
    var body: some View {
        viewForState(currentState)
    }
    
    @ViewBuilder
    private func viewForState(_ state: LoginState) -> some View {
        switch state {
        case .Landing:
            LoginLandingView(service: self.service, email: $name, password: $password, currentState: $currentState)
        case .Verification:
            LoginVerificationView(name: $name, password: $password, service: self.service)
        case .bioRecordChange:
            BiometricRevokedView(currentState: $currentState, text: "BiometricRecordChanged.Text1")
        case .bioRevoked:
            BiometricRevokedView(currentState: $currentState, text: "BiometricRevoked.text")
        }
    }
    
}

//#Preview {
//    UnauthenticatedMainView()
//}
