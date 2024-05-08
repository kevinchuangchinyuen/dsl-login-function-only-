//
//  ProfileUpdateMainVie.swift
//  dsl
//
//  Created by chuang chin yuen on 21/2/2024.
//

import SwiftUI

enum ProfileUpdateState{
    case Landing
    case Success
}


struct ProfileUpdateMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState
    
    @State private var profileUpdatecurrentState: ProfileUpdateState = .Landing

    var body: some View {
        viewForState(profileUpdatecurrentState)
    }
    
    @ViewBuilder
    private func viewForState(_ state: ProfileUpdateState) -> some View {
        switch state {
        case .Landing:
            ProfileUpdateLandingView(service: self.service.getProfileUpdateViewService(), currentState: self.$profileUpdatecurrentState, authservice: self.service, authcurrentState: self.$currentState)
        case .Success:
            ProfileUpdateSuccessView(authservice: self.service, authcurrentState: self.$currentState)
        }
    }

}

//#Preview {
//    ProfileUpdateMainView()
//}
