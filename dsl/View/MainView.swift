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
                    //                Button(action: {
                    //                    print(self.service.state.getAuthState.isAuthorized)
                    //                }) {
                    //                    Text("Hello")
                    //                        .foregroundColor(Color.ButtonBlue)
                    //                        .contentStyle()
                    //                }
                }
            }
//            .alert("Announcement.alert".localized(localizationManager.language), isPresented: $isShowingAnnouncement) {
//                Button("FIrstimeLinkUp.success.button".localized(localizationManager.language), role: .none) {
//                    
//                }
//            } message: {
//                if Locale.preferredLanguages.first == "en"{
//                    Text(contentEngString)
//                        .multilineTextAlignment(.leading)
//                }
//                else if Locale.preferredLanguages.first == "zh-HK"{
//                    Text(contentZHTString)
//                }
//                else if Locale.preferredLanguages.first == "zh-Hant"{
//                    Text(contentZHTString)
//                }
//                else if Locale.preferredLanguages.first == "zh-Hans"{
//                    Text(contentZHSString)
//                }
//            }
//            .onAppear {
//                self.service.getFooterInfo(number: 4){content in
//                    if content != nil{
//                        self.content = content
//                        self.contentEngString = content.content_en.htmlToAttributedString!.string
//                        self.contentZHSString = content.content_zh_cn.htmlToAttributedString!.string
//                        self.contentZHTString = content.content_zh_hk.htmlToAttributedString!.string
//                        isShowingAnnouncement = true
//                    }
//                    else{
//                        isShowingAnnouncement = false
//                    }
//                }
//            }

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
