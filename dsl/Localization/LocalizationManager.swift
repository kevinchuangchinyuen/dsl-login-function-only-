//
//  LocalizationManager.swift
//  dsl
//
//  Created by chuang chin yuen on 26/1/2024.
//

import Foundation
import SwiftUI

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
