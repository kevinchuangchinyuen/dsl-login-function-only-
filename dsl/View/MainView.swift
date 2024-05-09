//
//  MainView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import SwiftUI

enum MainState{
    case unauthenticated
    case authenticated
}

struct MainView: View {
    
    @ObservedObject private var service: MainViewService

    @State private var isShowingAnnouncement = false
    
    @State private var content: Content? = nil
    
    @State private var contentEngString: String = ""
    
    @State private var contentZHSString: String = ""

    @State private var contentZHTString: String = ""
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    init(service: MainViewService) {
        self.service = service
    }

    var body: some View {
        ZStack{
            ZStack{
                if !self.service.state.getAuthState.isAuthorized {
                    UnauthenticatedMainView(service: service.getUnauthenticatedViewService())
                }
                else {
                    AuthenticatedMainView(service: service.getAuthenticatedViewService())
                }
            }

            if self.service.isLoading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3)
            }
        }
        .disabled(self.service.isLoading)
        .onAppear {
            //getAndSetIpAddress()
        }
    }
    
    func startNetworkCall(){
        self.service.onLoading()
    }
    
    func getAndSetIpAddress(){
        self.service.getPublicIpAddress { result in
            switch result {
            case .success(let ipAddress):
                print("My public IP address is: \(ipAddress)")
                self.service.state.getSetIpAddress = ipAddress
            case .failure(let error):
                print("Error fetching public IP address: \(error)")
            }
        }
    }
        
}

//#Preview {
//    MainView()
//}
