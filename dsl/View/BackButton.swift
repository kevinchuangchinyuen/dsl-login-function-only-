//
//  BackButton.swift
//  dsl
//
//  Created by chuang chin yuen on 18/1/2024.
//

import SwiftUI

struct BackButton: View {
    var presentationMode: Binding<PresentationMode>
    
    init(presentationMode: Binding<PresentationMode>) {
        self.presentationMode = presentationMode
    }

    var body: some View {
        
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        })
        {
            ZStack(alignment: .leading) {
                Image("BackIcon")
            }
//            .padding(
//                EdgeInsets(top: 2.50, leading: 25 , bottom: 2.50, trailing: 0)
//            )
        }
        .frame(width: 30, height: 30)
    }
}


//#Preview {
//    BackButton()
//}
