//
//  AppVerErrorView.swift
//  dsl
//
//  Created by chuang chin yuen on 28/2/2024.
//

import SwiftUI

struct AppVerErrorView: View {

    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {

        NavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(spacing: 40){
                    Image(systemName: "arrow.up.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("AppVersionError.text1".localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text("AppVersionError.text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 350)
                }
                .customLeftRightPadding()

//                Spacer().frame(height: 350)

                VStack(){
                    
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://apps.apple.com/")!)
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("AppVersionError.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 20)

                }
                
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

//struct AppVerErrorView: View {
//    
//    @EnvironmentObject var localizationManager: LocalizationManager
//
//    var body: some View {
//        
//        NavigationView{
//            
//            ZStack{
//                Color.BackgroundBlue
//                    .ignoresSafeArea()
//                                
//                VStack{
//                    
//                    VStack(spacing: 40){
//                        Image(systemName: "arrow.up.circle")
//                            .resizable()
//                            .frame(width: 80, height: 80)
//                            .foregroundColor(Color.ButtonBlue)
//                        
//                        Text("AppVersionError.text1".localized(localizationManager.language))
//                            .titleStyle()
//                            .multilineTextAlignment(.center)
//                        //.lineLimit(nil)
//                        
//                        Text("AppVersionError.text2".localized(localizationManager.language))
//                            .contentStyle()
//                            .multilineTextAlignment(.center)
//                        //.lineLimit(nil)
//                    }
//                    
//                    Spacer().frame(height: 50)
//                    
//                    Button(action: {
//                        UIApplication.shared.open(URL(string: "https://apps.apple.com/")!)
//                    }){
//                        ZStack() {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(height: 58)
//                                .background(Color.ButtonBlue)
//                                .cornerRadius(4)
//                            Text("AppVersionError.button1".localized(localizationManager.language))
//                                .foregroundColor(.white)
//                                .titleWithoutBoldStyle()
//                        }
//                    }
//                
//                }
//                .customLeftRightPadding()
//                
//            }
//            
//        }
//        .navigationBarHidden(true)
//    }
//}

#Preview {
    AppVerErrorView()
}
