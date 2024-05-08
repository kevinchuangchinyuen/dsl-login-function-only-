//
//  BiometricRecordChangedView.swift
//  dsl
//
//  Created by chuang chin yuen on 14/2/2024.
//

import SwiftUI

struct BiometricRevokedView: View {
    
    @Binding var currentState: LoginState
    
    @State var text : String

    @EnvironmentObject var localizationManager: LocalizationManager

    //@Environment(\.presentationMode) private var presentationMode

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
                    
                    Text(text.localized(localizationManager.language))
                        .titleStyle()
                        .multilineTextAlignment(.center)
                    
                    Text("BiometricRecordChanged.Text2".localized(localizationManager.language))
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 280)

                }
                .customLeftRightPadding()
                
                VStack(){
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        currentState = .Landing
                        //presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("BiometricRecordChanged.Button1".localized(localizationManager.language))
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

//#Preview {
//    BiometricRecordChangedView()
//}
