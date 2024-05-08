//
//  OsErrorView.swift
//  dsl
//
//  Created by chuang chin yuen on 28/2/2024.
//

import SwiftUI

struct OsErrorView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        
        NavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(spacing: 40){
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("OsVersionError.text1".localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                        //.lineLimit(nil)
                    
                    
                    Text("OsVersionError.text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 370)

                }
                //.padding(EdgeInsets(top: 0, leading: 25, bottom: 370, trailing: 25))
                .customLeftRightPadding()

//                Spacer().frame(height: 370)
                
                VStack(){
                                        
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("OsVersionError.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
//                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 20, trailing: 25))
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 20)
                    
                    Button(action: {
                        exit(0)
                    }){
                        ZStack() {
                            Text("OsVersionError.button2".localized(localizationManager.language))
                                .foregroundColor(.black)
                                .contentStyle()
                        }
                    }
                    .customLeftRightPadding()
                                                            
                }
                
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    OsErrorView()
}
