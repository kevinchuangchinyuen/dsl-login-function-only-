//
//  DeleteAccountMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/2/2024.
//

import SwiftUI

enum DeleteAccountState{
    case Landing
    case Confirm
    case Success
}

struct DeleteAccountMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState

    @State private var deletecurrentState: DeleteAccountState = .Landing

    var body: some View {
        NavigationView(){
            viewForState(deletecurrentState)
                .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func viewForState(_ state: DeleteAccountState) -> some View {
        switch state {
        case .Landing:
            DeleteLandingView(service: self.service, currentState: self.$currentState, deletecurrentState: self.$deletecurrentState)
        case .Confirm:
            DeleteConfirmView(currentState: self.$currentState, deletecurrentState: self.$deletecurrentState, service: self.service)
        case .Success:
            DeleteSuccessView(service: self.service)
        }
    }
    
}


//#Preview {
//    DeleteAccountMainView()
//}
