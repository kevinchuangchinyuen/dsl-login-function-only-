//
//  AboutThisAppView.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import SwiftUI

struct AboutThisAppView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.presentationMode) private var presentationMode

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    init(presentationMode: Binding<PresentationMode>) {
        presentationModeMenu = presentationMode
        //self.state = state
    }
    
    var presentationModeMenu: Binding<PresentationMode>

    
    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        BackButton(presentationMode: self.presentationMode)
                        
                        Spacer()
                        
                        Text("About This App".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    
                    Spacer().frame(height: 90)
                    
                    Image("PoliceBigIcon")
                        .resizable()
                        .frame(width: 250, height: 250)
                    
                    Spacer().frame(height: 90)
                    
                    Text("AboutThisApp.text".localized(localizationManager.language) + "v" +  (appVersion ?? "Not found") )
                        .contentStyle()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .customLeftRightPadding()
                .navigationBarHidden(true)
            }
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    AboutThisAppView()
//}
