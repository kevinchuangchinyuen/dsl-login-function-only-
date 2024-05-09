//
//  CloseButton.swift
//  dsl
//
//  Created by chuang chin yuen on 19/1/2024.
//

import SwiftUI

struct CloseButton: View {
    
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
                Image("CloseIcon")
                    .resizable()
            }
        }
        .frame(width: 30, height: 30)
    }
}
