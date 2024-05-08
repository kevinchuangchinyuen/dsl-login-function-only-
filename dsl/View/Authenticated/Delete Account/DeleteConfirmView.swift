//
//  DeleteConfimView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/2/2024.
//

import SwiftUI

struct DeleteConfirmView: View {
    
    @Binding var currentState: AuthenticatedState
    
    @Binding var deletecurrentState: DeleteAccountState

    @ObservedObject var service: AuthenticatedViewService
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isChecked = false
    
    @State var isPostError = false
    
    var body: some View {
        
//        NavigationView(){
//            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        
                        Button(action: {
                            deletecurrentState = .Landing
                        })
                        {
                            ZStack(alignment: .leading) {
                                Image("BackIcon")
                            }
                        }
                        .frame(width: 30, height: 30)
                        
                        Spacer()
                        
                        Text("DeleteAccount.title".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        AuthenticatedMenuButton(service: self.service, currentState: $currentState)
                    }
                    
                    Spacer().frame(height: 70)

                    ScrollView(.vertical,showsIndicators: false){
                        
                        Text("DeleteAccount.landing.text".localized(localizationManager.language))
                            .contentStyle()
                        
                        
                        Spacer().frame(height: 70)
                        
                        Toggle(isOn: $isChecked) {
                            Text("DeleteAccount.confirm.text".localized(localizationManager.language))
                                .contentStyle()
                                .multilineTextAlignment(.leading)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        
                        Spacer().frame(height: 70)
                        
                        if(isPostError){
                            Text("ServerErrorMessage".localized(localizationManager.language))
                                .errorStyle()
                        }
                        
                        Button(action: {
                            self.service.deleteAccount(){statuscode in
                                if statuscode == 204 {
                                    deletecurrentState = .Success
                                }
                                else{
                                    isPostError = true
                                }
                            }
                        }){
                            ZStack() {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 58)
                                    .background(Color.ButtonBlue)
                                    .cornerRadius(4)
                                Text("DeleteAccount.confirm.button1".localized(localizationManager.language))
                                    .foregroundColor(.white)
                                    .titleWithoutBoldStyle()
                            }
                            .opacity(isChecked ? 1 : 0.7)
                        }
                        .disabled(!isChecked)
                        
                        Button(action: {
                            deletecurrentState = .Landing
                        }){
                            ZStack() {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 58)
                                    .background(Color.clear)
                                    .cornerRadius(4)
                                Text("DeleteAccount.confirm.button2".localized(localizationManager.language))
                                    .foregroundColor(.black)
                                    .titleWithoutBoldStyle()
                            }
                        }
                        
                        Spacer()
                    }
                    
                }  
                .customLeftRightPadding()

            }
//            .navigationBarHidden(true)
//        }
//        .navigationBarHidden(true)
    }

}

//#Preview {
//    DeleteConfirmView()
//}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {

            // 2
            configuration.isOn.toggle()

        }, label: {
            HStack {
                // 3
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.ButtonBlue)

                configuration.label
            }
        })
    }
}
