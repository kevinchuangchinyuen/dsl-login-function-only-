//
//  DeleteSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/2/2024.
//

import SwiftUI

struct DeleteSuccessView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        
//        NavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(spacing: 40){
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("DeleteAccount.success.text1".localized(localizationManager.language))
                        .titleStyle()
                    
                    Text("DeleteAccount.success.text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 330)
                }
                .customLeftRightPadding()

                VStack(){
                                        
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        self.service.startLogout()
                        //presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("DeleteAccount.success.button".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                    
                }
                
            }
//        }
//        .navigationBarHidden(true)
    }
}

//#Preview {
//    DeleteSuccessView()
//}
