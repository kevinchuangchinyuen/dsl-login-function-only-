//
//  LinkupBiometricView.swift
//  dsl
//
//  Created by chuang chin yuen on 27/2/2024.
//

import SwiftUI

struct LinkupBiometricView: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: 50){
            
            VStack(alignment: .leading){
                Text("LinkUp.linkedup.text2".localized(localizationManager.language))
                    .contentStyle()
                    .multilineTextAlignment(.leading)
            }
                        
            Image(systemName: "\(self.service.getBiometricImage())")
                .resizable()
                .frame(width: 100 ,height: 100)
                .foregroundColor(Color.ButtonBlue)

            Button(action: {
//                onEmailChecking()
//                onPasswordChecking()
//                self.endTextEditing()
//                
//                guard !isEmailError && !isPasswordError else {
//                    password = ""
//                    return
//                }
//                service.sendAuthenticationRequestLab(username: email, password: password) { statusCode in
//                    handleAuthenticationResponse(statusCode: statusCode)
//                }
//
            }){
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 58)
                        .background(Color.ButtonBlue)
                        .cornerRadius(4)
                    Text("LinkUp.linkedup.button".localized(localizationManager.language))
                        .foregroundColor(.white)
                        .titleWithoutBoldStyle()
                }
            }
                        
        }
    }
    
    
}

//#Preview {
//    LinkupBiometricView()
//}
