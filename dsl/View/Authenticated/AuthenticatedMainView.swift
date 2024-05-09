//
//  AuthenticatedMainView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import SwiftUI


enum AuthenticatedState{
    case Home
    case Blank
}

struct AuthenticatedMainView: View {
    
    @ObservedObject var service: AuthenticatedViewService

    @State private var currentState: AuthenticatedState = .Home
    
    @State var timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()
    
    var body: some View {
        viewForState(currentState)
            .onAppear {
                self.service.processTokens()
                self.currentState = getCurrentState()
                self.service.checkBiometricEnabled()
//                print(self.service.calculateLifetime())
                timer.upstream.connect().cancel()
                timer = Timer.publish (every: TimeInterval(self.service.calculateLifetime()), on: .current, in: .common).autoconnect()
            }
            .onReceive(timer) { _ in
                print("timeout")
                timer.upstream.connect().cancel()
                self.service.startLogout()
            }
    }
    
    @ViewBuilder
    private func viewForState(_ state: AuthenticatedState) -> some View {
        switch state {
        case .Home:
            HomeView(service: self.service,currentState: self.$currentState)
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
