//
//  inactivity timer.swift
//  dsl
//
//  Created by chuang chin yuen on 13/3/2024.
//

import Foundation
import SwiftUI

class ActivityDetector: NSObject {
    
    private typealias SendEventFunc = @convention(c) (AnyObject, Selector, UIEvent) -> Void
    
    @objc func mySendEvent(_ event: UIEvent) {
        
        unsafeBitCast(
            class_getMethodImplementation(ActivityDetector.self, #selector(mySendEvent)),
            to: SendEventFunc.self
        )(self, #selector(UIApplication.sendEvent), event)

        // send a notification, just like in the non-SwiftUI solutions
        NotificationCenter.default.post(name: .init("UserActivity"), object: nil)
    }
}
