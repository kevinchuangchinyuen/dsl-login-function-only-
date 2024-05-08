//
//  ForgotPasswordSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 16/2/2024.
//

import SwiftUI

struct ForgotPasswordSuccessView: View {
    
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        NavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(alignment: .center, spacing: 40){
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("ForgotPassword.success.text".localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 300)
                }
                .customLeftRightPadding()

//                Spacer().frame(height: 300)

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
                            Text("ForgotPassword.success.button".localized(localizationManager.language))
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
    ForgotPasswordSuccessView()
}
