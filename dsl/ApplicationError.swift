//
//  ApplicationError.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import os.log

struct Logger {
    
    static func error(data: String) {
        os_log("%s", type: .error, data)
    }

    static func info(data: String) {
        os_log("%s", type: .info, data)
    }

    static func debug(data: String) {
        os_log("%s", type: .debug, data)
    }
}

class ApplicationError: Error {
    
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

