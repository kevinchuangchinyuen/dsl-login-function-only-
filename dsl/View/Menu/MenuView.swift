//
//  MenuView.swift
//  dsl
//
//  Created by chuang chin yuen on 19/1/2024.
//

import SwiftUI

struct UnauthenticatedMenuButton: View {
    
    var body: some View {
        NavigationLink(destination: UnauthenticatedMenuView())
        {
            ZStack(alignment: .leading) {
                Image("MenuIcon")
                    .resizable()
            }
        }
        .frame(width: 30, height: 30)
    }
}

struct AuthenticatedMenuButton: View {
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: AuthenticatedState

    var body: some View {
        NavigationLink(destination: AuthenticatedMenuView(service: self.service, currentState: $currentState))
        {
            ZStack(alignment: .leading) {
                Image("MenuIcon")
                    .resizable()
            }
        }
        .frame(width: 30, height: 30)
    }
}

struct UnauthenticatedMenuView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        NavigationView {
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
                        Spacer().frame(width: 30, height: 30)

                        Spacer()
                        
                        Text("Menu".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationMode)
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 70)
                    
                    List{
                        NavigationLink(destination: UnauthenticatedSettingView(presentationMode: self.presentationMode)){
                            Text("Setting".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                        NavigationLink(destination: AccessibilityDesignView(presentationMode: self.presentationMode)){
                            Text("Accessibility Design".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                        NavigationLink(destination: AboutThisAppView(presentationMode: self.presentationMode)){
                            Text("About This App".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    
                    //Spacer().frame(height: 20)

                    Text("v" + (appVersion ?? "Not found"))
                        .foregroundColor(.gray)
                        .contentStyle()

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

struct AuthenticatedMenuView: View {
    
    @ObservedObject var service: AuthenticatedViewService
        
    @Binding var currentState: AuthenticatedState

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var localizationManager: LocalizationManager
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        NavigationView{
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()
                
                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
                        Spacer().frame(width: 30, height: 30)

                        Spacer()
                        
                        Text("Menu".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationMode)
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 70)
                    
                    List{
                        NavigationLink(destination: UnauthenticatedSettingView(presentationMode: self.presentationMode)){
                            Text("Setting".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                        NavigationLink(destination: AccessibilityDesignView(presentationMode: self.presentationMode)){
                            Text("Accessibility Design".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                        NavigationLink(destination: AboutThisAppView(presentationMode: self.presentationMode)){
                            Text("About This App".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                        Button(action: {
                            //self.presentationMode.wrappedValue.dismiss()
                            self.service.startLogout()
                        }){
                            Text("Logout".localized(localizationManager.language))
                                .smallTitleStyle()
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    
                    Text("v" + (appVersion ?? "Not found"))
                        .foregroundColor(.gray)
                        .contentStyle()

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}


//#Preview {
//    UnauthenticatedMenuView()
//}
