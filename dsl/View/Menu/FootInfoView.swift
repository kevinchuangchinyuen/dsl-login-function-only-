//
//  ImportantNoticesView.swift
//  dsl
//
//  Created by chuang chin yuen on 15/3/2024.
//

import SwiftUI
import Alamofire

struct FootInfoView2: View {
    private let mainService: MainViewService

    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) private var presentationMode

    @State private var content: Content?

    @State private var contentEngString: String = ""
    @State private var contentZHSString: String = ""
    @State private var contentZHTString: String = ""

    @Binding var number: Int

    init(number: Int, presentationMode: Binding<PresentationMode>) {
        self._number = Binding.constant(number)
        self.presentationModeMenu = presentationMode
        self.mainService = MainViewService()
    }
    
    var presentationModeMenu: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            ZStack {
                Color.BackgroundBlue
                    .ignoresSafeArea()

                VStack {
                    Spacer().frame(height: 10)

                    HStack {
                        BackButton(presentationMode: self.presentationMode)
                        Spacer()

                        Text(titleForNumber(number))
                            .titleStyle()

                        Spacer()

                        CloseButton(presentationMode: self.presentationModeMenu)
                    }

                    Spacer().frame(height: 70)

                    ScrollView(.vertical, showsIndicators: false) {
                        if let content = content {
                            renderContent(content: content)
                        }
                    }

                    Spacer()
                }
                .customLeftRightPadding()
            }
            .onAppear {
                self.mainService.getFooterInfo(number: self.number) { content in
                    self.content = content
                    updateContentStrings(content: content)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }

    func titleForNumber(_ number: Int) -> String {
        switch number {
        case 1:
            return "Important Notices".localized(localizationManager.language)
        case 2:
            return "Privacy Policy".localized(localizationManager.language)
        case 3:
            return "FAQs".localized(localizationManager.language)
        default:
            return ""
        }
    }

    func updateContentStrings(content: Content) {
        contentEngString = content.content_en
        contentZHSString = content.content_zh_cn
        contentZHTString = content.content_zh_hk
        print(contentEngString)
    }

    func renderContent(content: Content) -> some View {
        if Locale.preferredLanguages.first == "en" {
            AttributedText(.html(withBody: contentEngString))
        } else if Locale.preferredLanguages.first == "zh-HK" {
            AttributedText(.html(withBody: contentZHTString))
        } else if Locale.preferredLanguages.first == "zh-Hant" {
            AttributedText(.html(withBody: contentZHTString))
        } else if Locale.preferredLanguages.first == "zh-Hans" {
            AttributedText(.html(withBody: contentZHSString))
        } else {
            AttributedText(.html(withBody: contentEngString))
        }
    }
}

struct FootInfoView1: View {
    
    private let mainService: MainViewService

    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var content: Content? = nil
    
    @State private var contentEngString: String = ""
    
    @State private var contentZHSString: String = ""

    @State private var contentZHTString: String = ""
    
    @Binding var number : Int
    
    init(number: Int, presentationMode: Binding<PresentationMode>) {
        self._number = Binding.constant(number)
        self.presentationModeMenu = presentationMode
        self.mainService = MainViewService()
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
                        
                        if number == 1{
                            Text("Important Notices".localized(localizationManager.language))
                                .titleStyle()
                        }
                        else if number == 2{
                            Text("Privacy Policy".localized(localizationManager.language))
                                .titleStyle()
                        }
                        if number == 3{
                            Text("FAQs".localized(localizationManager.language))
                                .titleStyle()
                        }
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    
                    Spacer().frame(height: 70)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        if Locale.preferredLanguages.first == "en"{
                            AttributedText(.html(withBody: """
                              \(contentEngString)
                              """))
                            //                            Text(contentEngString)
                            //                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-HK"{
                            AttributedText(.html(withBody: """
                              \(contentZHTString)
                              """))
//                            Text(contentZHTString)
//                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-Hant"{
                            AttributedText(.html(withBody: """
                              \(contentZHTString)
                              """))
//                            Text(contentZHTString)
//                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-Hans"{
                            AttributedText(.html(withBody: """
                              \(contentZHSString)
                              """))
//                            Text(contentZHSString)
//                                .contentStyle()
                        }
                    }
                    
                    Spacer()
                }
                .customLeftRightPadding()
                .navigationBarHidden(true)
            }
            .onAppear{
                self.mainService.getFooterInfo(number: self.number){content in
                    self.content = content
//                    self.contentEngString = content.content_en.htmlToAttributedString!.string
//                    self.contentZHSString = content.content_zh_cn.htmlToAttributedString!.string
//                    self.contentZHTString = content.content_zh_hk.htmlToAttributedString!.string
                    self.contentEngString = content.content_en
                    self.contentZHSString = content.content_zh_cn
                    self.contentZHTString = content.content_zh_hk
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct FootInfoView: View {
    
    private let mainService: MainViewService

    @EnvironmentObject var localizationManager: LocalizationManager
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var content: Content? = nil
    
    @State private var contentEngString: String = ""
    
    @State private var contentZHSString: String = ""

    @State private var contentZHTString: String = ""
    
    @Binding var number : Int
    
    init(number: Int, presentationMode: Binding<PresentationMode>) {
        self._number = Binding.constant(number)
        self.presentationModeMenu = presentationMode
        self.mainService = MainViewService()
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
                        
                        if number == 1{
                            Text("Important Notices".localized(localizationManager.language))
                                .titleStyle()
                        }
                        else if number == 2{
                            Text("Privacy Policy".localized(localizationManager.language))
                                .titleStyle()
                        }
                        if number == 3{
                            Text("FAQs".localized(localizationManager.language))
                                .titleStyle()
                        }
                        
                        Spacer()
                        
                        CloseButton(presentationMode: self.presentationModeMenu)
                    }
                    
                    Spacer().frame(height: 70)
                    
                    ScrollView(.vertical,showsIndicators: false){
                        if Locale.preferredLanguages.first == "en"{
                            Text(contentEngString)
                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-HK"{
//                            AttributedText(.html(withBody: """
//                              \(contentZHTString)
//                              """))
                            Text(contentZHTString)
                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-Hant"{
//                            AttributedText(.html(withBody: """
//                              \(contentZHTString)
//                              """))
                            Text(contentZHTString)
                                .contentStyle()
                        }
                        else if Locale.preferredLanguages.first == "zh-Hans"{
//                            AttributedText(.html(withBody: """
//                              \(contentZHSString)
//                              """))
                            Text(contentZHSString)
                                .contentStyle()
                        }
                    }
                    
                    Spacer()
                }
                .customLeftRightPadding()
                .navigationBarHidden(true)
            }
            .onAppear{
                self.mainService.getFooterInfo(number: self.number){content in
                    self.content = content
                    self.contentEngString = content.content_en.htmlToAttributedString!.string
                    self.contentZHSString = content.content_zh_cn.htmlToAttributedString!.string
                    self.contentZHTString = content.content_zh_hk.htmlToAttributedString!.string
                }
            }
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    ImportantNoticesView()
//}
