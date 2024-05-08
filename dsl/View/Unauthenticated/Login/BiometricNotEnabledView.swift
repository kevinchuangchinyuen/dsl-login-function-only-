//
//  BiometricNotEnabledView.swift
//  dsl
//
//  Created by chuang chin yuen on 7/2/2024.
//

import SwiftUI

struct BiometricNotEnabledView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    @Environment(\.presentationMode) private var presentationMode

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
                    
                    Text("BiometricNotEnabled.text1".localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text("BiometricNotEnabled.text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 280)
                }
                .customLeftRightPadding()
                
                VStack(){
                                        
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("BiometricNotEnabled.button1".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
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
    BiometricNotEnabledView()
}
