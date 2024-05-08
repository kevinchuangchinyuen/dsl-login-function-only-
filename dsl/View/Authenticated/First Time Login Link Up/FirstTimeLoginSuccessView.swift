//
//  FirstTimeLoginSuccessView.swift
//  dsl
//
//  Created by chuang chin yuen on 8/3/2024.
//

import SwiftUI

struct FirstTimeLoginSuccessView: View {
    
    @Binding var currentState: AuthenticatedState

    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: 30){
            
            Text("LinkUp.success.text1".localized(localizationManager.language))
                .titleWithoutBoldStyle()

            Text("LinkUp.success.text2".localized(localizationManager.language))
                .contentStyle()
                .multilineTextAlignment(.leading)

            Button(action: {
                currentState = .Home
            }){
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 58)
                        .background(Color.ButtonBlue)
                        .cornerRadius(4)
                    Text("FIrstimeLinkUp.success.button".localized(localizationManager.language))
                        .foregroundColor(.white)
                        .titleWithoutBoldStyle()
                }
            }
        }
    }
}

//#Preview {
//    FirstTimeLoginSuccessView()
//}
