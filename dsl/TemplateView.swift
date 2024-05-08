//
//  TestView.swift
//  dsl
//
//  Created by chuang chin yuen on 17/1/2024.
//

import SwiftUI

struct TemplateView: View {
    
    @State private var isLoading = false
    //@EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) private var presentationMode


    var body: some View {
        CustomNavigationView{
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                                
                VStack(spacing: 40){
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.ButtonBlue)
                    
                    Text("RegisterSuccess.text1")
                        .titleStyle()
                    
                    Text("RegisterSuccess.text2")
                        .contentStyle()
                }
                .customLeftRightPadding()

                Spacer().frame(height: 300)

                VStack(){
                                        
                    Spacer().frame(height: 50)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(13)
                            Text("RegisterSuccess.button")
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                                                            
                }
            }

        }
        .navigationBarHidden(true)

    }
    
    func fetchData() {
        isLoading = true
        
        // Perform Alamofire request
//        AF.request("https://api.example.com/data").responseJSON { response in
//            // Handle the response
//            
//            isLoading = false
//        }
    }
}

#Preview {
    TemplateView()
}


//struct securedTextField: View {
//    
//    @State private var text = ""
//    @State var hideKeyboard: (() -> Void)?
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            
//            Group {
//                SecureField("Enter Text", text: $text)
//                    .textInputAutocapitalization(.never)
//                    .keyboardType(.asciiCapable) // This avoids suggestions bar on the keyboard.
//                    .autocorrectionDisabled(true)
//                    .padding(.bottom, 7)
//                    .overlay(
//                        Rectangle().frame(width: nil, height: 1, alignment: .bottom)
//                            .foregroundColor(Color.gray),
//                        alignment: .bottom
//                    )
//                    .focused($focusedField, equals: .hidePasswordField)
//                    .opacity(hidePasswordFieldOpacity.rawValue)
//                
//                TextField("Enter Text", text: $text)
//                    .textInputAutocapitalization(.never)
//                    .keyboardType(.asciiCapable)
//                    .autocorrectionDisabled(true)
//                    .padding(.bottom, 7)
//                    .overlay(
//                        Rectangle().frame(width: nil, height: 1, alignment: .bottom)
//                            .foregroundColor(Color.gray),
//                        alignment: .bottom
//                    )
//                    .focused($focusedField, equals: .showPasswordField)
//                    .opacity(showPasswordFieldOpacity.rawValue)
//            }
//            
//            Button(action: {
//                performToggle()
//            }, label: {
//                Image(systemName: self.isSecured ? "eye.slash" : "eye")
//                    .accentColor(.gray)
//            })
//            
//        }
//    }
//    
//    func performToggle() {
//        isSecured.toggle()
//
//        if isSecured {
//            focusedField = .hidePasswordField
//        } else {
//            focusedField = .showPasswordField
//        }
//
//        hidePasswordFieldOpacity.toggle()
//        showPasswordFieldOpacity.toggle()
//    }
//
//}
