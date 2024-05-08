//
//  dslApp.swift
//  dsl
//
//  Created by chuang chin yuen on 16/1/2024.
//

import SwiftUI

@main
struct EntryPoint {
    // swizzle here
    static func main() {
        let original = class_getInstanceMethod(UIApplication.self, #selector(UIApplication.sendEvent))!
        let new = class_getInstanceMethod(ActivityDetector.self, #selector(ActivityDetector.mySendEvent))!
        method_exchangeImplementations(original, new)

        // launch your app
        dslApp.main()
    }
}

struct dslApp: App {
    
    private let mainService: MainViewService
    
    init(){
        self.mainService = MainViewService()
    }

    var body: some Scene {
        WindowGroup {
            ValidationView(service: self.mainService)
                .environmentObject(LocalizationManager.shared)
        }
    }
}
