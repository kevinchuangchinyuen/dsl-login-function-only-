//
//  RegistrationSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import SwiftUI

struct RegistrationSuccessView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(spacing: 40){
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("RegisterSuccess.text1".localized(localizationManager.language))
                        .titleStyle()
                    
                    Text("RegisterSuccess.text2".localized(localizationManager.language) + "!")
                        .contentStyle()
                    
                    Spacer().frame(height: 300)
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
                            Text("RegisterSuccess.button".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                                                            
                }
                
            }
        }
        .navigationBarHidden(true)

    }
}

#Preview {
    RegistrationSuccessView()
}
