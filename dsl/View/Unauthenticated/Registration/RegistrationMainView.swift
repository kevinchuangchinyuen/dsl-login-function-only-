//
//  RegistrationMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import SwiftUI

enum RegistrationState {
    case form
    case success
    // Add more states as needed
}

struct RegistrationMainView: View {
    
    @ObservedObject var service: RegistrationViewService
    
    @State private var currentState: RegistrationState = .form

    var body: some View {
        viewForState(currentState)
    }
    
    @ViewBuilder
    private func viewForState(_ state: RegistrationState) -> some View {
        switch state {
        case .form:
            RegistrationLandingView(service: self.service, currentState: $currentState)
        case .success:
            RegistrationSuccessView()
        }
    }
}

//#Preview {
//    RegistrationMainView()
//}
