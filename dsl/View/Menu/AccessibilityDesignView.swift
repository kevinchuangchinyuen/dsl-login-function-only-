//
//  AccessibilityDesignView.swift
//  dsl
//
//  Created by chuang chin yuen on 22/2/2024.
//

import SwiftUI

struct AccessibilityDesignView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.presentationMode) private var presentationMode

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
                        
                        Text("Accessibility Design".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    
                    Spacer().frame(height: 90)
                                        
                    VStack() {
                        Text("AccessibilityDesign.text".localized(localizationManager.language))
                            .contentStyle()
                                                                    
                        Spacer()
                    }
                }
                .customLeftRightPadding()
                .navigationBarHidden(true)
            }
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    AccessibilityDesignView()
//}
