//
//  LocalizationManager.swift
//  dsl
//
//  Created by chuang chin yuen on 26/1/2024.
//

import Foundation
import SwiftUI

//protocol LocalizationDelegate: AnyObject {
//    func resetApp()
//}
//
//class LocalizationManager: NSObject {
//    enum LanguageDirection {
//        case leftToRight
//        case rightToLeft
//    }
//    
//    enum Language: String {
//        case English = "en"
//        case TradChinese = "zh-Hant"
//        case SimChinese = "zh-Hans"
//    }
//    
//    static let shared = LocalizationManager()
//    private var bundle: Bundle? = nil
//    private var languageKey = "AppleLanguages"
//    weak var delegate: LocalizationDelegate?
//    
//    // get currently selected language from el user defaults
//    func getLanguage() -> Language? {
//        if let languageCode = UserDefaults.standard.string(forKey: languageKey), let language = Language(rawValue: languageCode) {
//            return language
//        }
//        return nil
//    }
//    
//    // check if the language is available
//    private func isLanguageAvailable(_ code: String) -> Language? {
//        var finalCode = ""
//        if code.contains("en") {
//            finalCode = "en"
//        } else if code.contains("zh-Hant") {
//            finalCode = "zh-Hant"
//        }
//        else if code.contains("zh-Hans") {
//            finalCode = "zh-Hans"
//        }
//        return Language(rawValue: finalCode)
//    }
//    
//    // check the language direction
//    private func getLanguageDirection() -> LanguageDirection {
//        if let lang = getLanguage() {
//            switch lang {
//            case .English:
//                return .leftToRight
//            case .TradChinese:
//                return .rightToLeft
//            case .SimChinese:
//                return .rightToLeft
//            }
//        }
//        return .leftToRight
//    }
//    
//    // get localized string for a given code from the active bundle
//    func localizedString(for key: String, value comment: String) -> String {
//        let localized = bundle!.localizedString(forKey: key, value: comment, table: nil)
//        return localized
//    }
//    
//    // set language for localization
////    func setLanguage(language: Language) {
////        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
////        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") {
////            bundle = Bundle(path: path)
////        } else {
////            // fallback
////            resetLocalization()
////        }
////        UserDefaults.standard.synchronize()
////        resetApp()
////    }
////    
//    func setLanguage(language: String) {
//        UserDefaults.standard.set(language, forKey: languageKey)
//        if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
//            bundle = Bundle(path: path)
//        } else {
//            // fallback
//            resetLocalization()
//        }
//        UserDefaults.standard.synchronize()
//        //resetApp()
//    }
//
//    
//    // reset bundle
//    func resetLocalization() {
//        bundle = Bundle.main
//    }
//    
//    // reset app for the new language
//    func resetApp() {
//        let dir = getLanguageDirection()
//        var semantic: UISemanticContentAttribute!
//        switch dir {
//        case .leftToRight:
//            semantic = .forceLeftToRight
//        case .rightToLeft:
//            semantic = .forceRightToLeft
//        }
//        UITabBar.appearance().semanticContentAttribute = semantic
//        UIView.appearance().semanticContentAttribute = semantic
//        UINavigationBar.appearance().semanticContentAttribute = semantic
//        delegate?.resetApp()
//    }
//    
//    // configure startup language
////    func setAppInnitLanguage() {
////        if let selectedLanguage = getLanguage() {
////            setLanguage(language: selectedLanguage)
////        } else {
////            // no language was selected
////            let languageCode = Locale.preferredLanguages.first
////            if let code = languageCode, let language = isLanguageAvailable(code) {
////                setLanguage(language: language)
////            } else {
////                // default fall back
////                setLanguage(language: .English)
////            }
////        }
////        resetApp()
////    }
//}
//
//extension String {
//    var localized: String {
//        return LocalizationManager.shared.localizedString(for: self, value: "")
//    }
//}

public enum SelectedLanguage: String {
    case English = "en"
    case TradChinese = "zh-Hant"
    case SimChinese = "zh-Hans"
}

public class LocalizationManager: ObservableObject { // Mark the class as ObservableObject
    // MARK: - Variables
    public static let shared = LocalizationManager()
  //  @AppStorage("selectedLanguage") private var languageString: String = SelectedLanguage.English.rawValue // First-time users would see English language
    @AppStorage("selectedLanguage") private var languageString: String = NSLocale.autoupdatingCurrent.languageCode!
    
    @Published public var language: SelectedLanguage = .TradChinese { // Match the initial language with languageString
        didSet {
            languageString = language.rawValue // We save the updated language's code into storage
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages") // Set the device's app language
            UserDefaults.standard.synchronize() // Optional as Apple does not recommend doing this
        }
    }
    
    // MARK: - Init
    public init() {
        // Added selected language initialization
        if let selectedLanguage = SelectedLanguage(rawValue: languageString) {
            language = selectedLanguage
        }
        //print(NSLocale.autoupdatingCurrent.languageCode)
//        if let deviceLanguage = Locale.preferredLanguages.first,
//           let selectedLanguage = SelectedLanguage(rawValue: deviceLanguage) {
//            language = selectedLanguage
//        } else {
//            // If the device system language is not available or not supported, fallback to the default language
//            if let selectedLanguage = SelectedLanguage(rawValue: languageString) {
//                language = selectedLanguage
//            }
//        }
        
    }
}

extension String {
    public func localized(_ language: SelectedLanguage) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("Failed to find path for language: \(language.rawValue)")
            return self
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

//extension DatePicker {
//    public func localized(_ language: SelectedLanguage) -> DatePicker {
//        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
//              let bundle = Bundle(path: path) else {
//            print("Failed to find path for language: \(language.rawValue)")
//            return self
//        }
//        //return DatePicker(self, bundle: bundle, comment: "")
//    }
//}
