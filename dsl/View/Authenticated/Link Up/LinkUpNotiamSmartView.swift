//
//  LinkUpNotiamSmartView.swift
//  dsl
//
//  Created by chuang chin yuen on 27/2/2024.
//

import SwiftUI

struct LinkUpNotIamSmartView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        
        VStack(alignment: .leading){
            
            Text("LinkUp.notlinkedup.title".localized(localizationManager.language))
                .smallTitleStyle()
                .multilineTextAlignment(.leading)
            
            Text("\n")
                .contentStyle()
            
            Text(LocalizedStringKey("LinkUp.notlinkedup.text1".localized(localizationManager.language)))
                .contentStyle()
                .multilineTextAlignment(.leading)
            
            Text("\n")
                .contentStyle()
            
            Text("LinkUp.notlinkedup.text2".localized(localizationManager.language))
                .contentStyle()
                .multilineTextAlignment(.leading)
            
            Text("\n")
                .contentStyle()
            
            Text("LinkUp.notlinkedup.text3".localized(localizationManager.language))
                .contentStyle()
                .multilineTextAlignment(.leading)

        }
    }
}

//#Preview {
//    LinkUpNotiamSmartView()
//}
