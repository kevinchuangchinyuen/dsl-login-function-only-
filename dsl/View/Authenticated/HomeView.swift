//
//  HomeView.swift
//  dsl
//
//  Created by chuang chin yuen on 14/2/2024.
//

enum DigitalSigningtate{
    case Request
    case Open
    case Result
}

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
//    @State var digitalSigningState: Bool = true
    
    @State private var digitalSigningState: DigitalSigningtate = .Request

    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack{
                    
                    Spacer().frame(height: 10)
                    
                    HStack{
                        HeaderView()
                        //Image("Header")
                        Spacer()
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    
                    Spacer().frame(height: 50)
                    
                    Text("Home".localized(localizationManager.language))
                        .titleStyle()
                    
                    Spacer().frame(height: 50)
                    
//                    if digitalSigningState == .Request{
//                        Button(action: {
//                            service.requestDigitalSigning()
//                            digitalSigningState = .Open
//                        }){
//                            ZStack() {
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .frame(height: 58)
//                                    .background(Color.iamSmartGreen)
//                                    .cornerRadius(13)
//                                HStack{
//                                    Image("Iamsmart")
//                                        .resizable()
//                                        .frame(width: 25, height: 33)
//                                        .foregroundColor(.white)
//                                    
//                                    Spacer().frame(width: 10)
//                                    
//                                    Text("RequestSigning.button".localized(localizationManager.language))
//                                        .foregroundColor(.white)
//                                        .titleWithoutBoldStyle()
//                                }
//                            }
//                        }
//                    }
//                    else if digitalSigningState == .Open{
//                        Text("請按照以下步驟: \n \n 1. 點擊以下「開啟智方便」按鈕來開啟你手機上的「智方便」應用程式\n \n 2. 請確保「智方便」顯示的識別碼相同\n \n 3. 點擊「簽署」以完成數碼簽署")
//                            .contentStyle()
//                        
//                        HStack{
//                            Button(action: {
//                                UIApplication.shared.open(URL(string: "\("hk.gov.iamsmart.testapp://hash-sign?ticketID=\(service.ticketId ?? "")")")!)
////                                UIApplication.shared.open(URL(string: "\("hk.gov.iamsmart.testapp://re-auth?ticketID=\(service.ticketId ?? "")")")!)
//                            }){
//                                ZStack() {
//                                    Rectangle()
//                                        .foregroundColor(.clear)
//                                        .frame(height: 58)
//                                        .background(Color.iamSmartGreen)
//                                        .cornerRadius(13)
//                                    HStack{
//                                        Image("Iamsmart")
//                                            .resizable()
//                                            .frame(width: 25, height: 33)
//                                            .foregroundColor(.white)
//                                        
//                                        Spacer().frame(width: 10)
//                                        
//                                        Text("OpeniAMSmart.button".localized(localizationManager.language))
//                                            .foregroundColor(.white)
//                                            .titleWithoutBoldStyle()
//                                    }
//                                }
//                                .frame(width: 200)
//                            }
//                            
//                            Spacer()
//                        }
//                    }
//                    else if digitalSigningState == .Result{
//                        Text("簽署成功")
//                            .contentStyle()
////                        Text("登入失敗,請重試")
////                            .contentStyle()
////                        Text("登入逾時,請重試")
////                            .contentStyle()
////                        Text("登入已取消,請重試")
////                            .contentStyle()
//                    }
                    
                    Spacer()
                }
                .customLeftRightPadding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
//            self.service.processTokens()
//            self.currentState = getCurrentState()
            self.service.checkBiometricEnabled()
        }
        .onOpenURL { url in
            print(url)
            digitalSigningState = .Result
//            let targetAppURLScheme = "com.ksm.kevin.app2"
//            let url = URL(string: "\(targetAppURLScheme)")!
//            UIApplication.shared.open(url)
            if let code = url.queryDictionary?["code"] {
                //                print(code)
                //                self.service.getIamsmartService().sendCodeToAuthEndpoint(code: code)
            }
            if let state = url.queryDictionary?["state"] {
                print(state)
            }
        }

    }
}

//#Preview {
//    HomeView()
//}
