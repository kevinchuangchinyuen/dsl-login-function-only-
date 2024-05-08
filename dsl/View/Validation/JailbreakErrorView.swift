//
//  JailbreakErrorView.swift
//  dsl
//
//  Created by chuang chin yuen on 28/2/2024.
//

import SwiftUI

struct JailbreakErrorView: View {
    
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
                    
                    Text("JailbreakError.text1".localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text("JailbreakError.text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 350)
                }
                .customLeftRightPadding()
                
//                Spacer().frame(height: 350)

                VStack(){
                                        
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        //presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("JailbreakError.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 20)

                    Button(action: {
                        exit(0)
                    }){
                        ZStack() {
                            Text("JailbreakError.button2".localized(localizationManager.language))
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
    JailbreakErrorView()
}
