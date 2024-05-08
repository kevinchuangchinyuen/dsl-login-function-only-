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

//struct CloseButton: View {
//    var presentationMode1: Binding<PresentationMode>?
//    var presentationMode2: Binding<PresentationMode>?
//    
//    init(presentationMode1: Binding<PresentationMode>? = nil, presentationMode2: Binding<PresentationMode>? = nil) {
//        self.presentationMode1 = presentationMode1
//        self.presentationMode2 = presentationMode2
//    }
//    
//    var body: some View {
//        Button(action: {
//            presentationMode1?.wrappedValue.dismiss()
//            presentationMode2?.wrappedValue.dismiss()
//        }) {
//            ZStack(alignment: .leading) {
//                Image("CloseIcon")
//                    .resizable()
//            }
//        }
//        .frame(width: 30, height: 30)
//    }
//}


//#Preview {
//    CloseButton()
//}
