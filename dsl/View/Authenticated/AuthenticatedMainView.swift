//
//  AuthenticatedMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import SwiftUI


enum AuthenticatedState{
    case BiometricEnable
    case FirstTimeLogin
    case Home
    case ProfileUpdate
    case ChangePassword
    case DeleteAccount
    case LinkUpAccount
    case Blank
}

struct AuthenticatedMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService

    @State private var currentState: AuthenticatedState = .Home
    
//    @State var presentAlert = false
    
    @State var timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()

    //@State private var inactivityTimer: Timer?
    
    var body: some View {
        //CustomNavigationView{
        viewForState(currentState)
        //            .alert("Foo", isPresented: $presentAlert) {
        //                Button("OK") {}
        //            }
        //.navigationBarHidden(true)
        
        //.navigationBarHidden(true)
            .onAppear {
                self.service.processTokens()
                self.currentState = getCurrentState()
                self.service.checkBiometricEnabled()
//                print(self.service.calculateLifetime())
                timer.upstream.connect().cancel()
                timer = Timer.publish (every: TimeInterval(self.service.calculateLifetime()), on: .current, in: .common).autoconnect()
            }
            .onReceive(timer) { _ in
                //                presentAlert = true
                print("timeout")
                timer.upstream.connect().cancel()
                self.service.startLogout()
            }
//         user did something!
//            .onReceive(NotificationCenter.default.publisher(for: .init("UserActivity")), perform: { _ in
//                timer.upstream.connect().cancel()
//                timer = Timer.publish (every: 60*60, on: .current, in: .common).autoconnect()
//            })
        
    }
    
    @ViewBuilder
    private func viewForState(_ state: AuthenticatedState) -> some View {
        switch state {
        case .BiometricEnable:
            BiometricEnableView(service: self.service,currentState: self.$currentState)
        case .FirstTimeLogin:
            FirstTimeLoginLinkUpMainView(service: self.service, currentState: self.$currentState)
        case .Home:
            HomeView(service: self.service,currentState: self.$currentState)
        case .ProfileUpdate:
            ProfileUpdateMainView(service: self.service,currentState: self.$currentState)
        case .ChangePassword:
            ChangePasswordMainView(service: self.service,currentState: self.$currentState, changePasswordService: self.service.getChangePasswordViewService())
        case .DeleteAccount:
            DeleteAccountMainView(service: self.service,currentState: self.$currentState)
        case .LinkUpAccount:
            LinkUpMainView(service: self.service,currentState: self.$currentState)
        case .Blank:
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
            }
        }
    }
    
    func getCurrentState() -> AuthenticatedState{
        return .Home
    }
    
//    @MainActor
//    func resetTask() {
//        task = Task {
//            try await Task.sleep(for: .seconds(60))
//            try Task.checkCancellation()
//            presentAlert = true
//        }
//    }

    
//    func restartInactivityTimer() {
//        inactivityTimer?.invalidate()
//        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
//            print("timeout")
//            self.service.startLogout()
//        }
//    }

}
