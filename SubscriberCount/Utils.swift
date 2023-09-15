//
//  Utils.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2022-09-21.
//  Copyright © 2022 Arjun Dureja. All rights reserved.
//

import Foundation

class Utils {
    static func isInWidget() -> Bool {
        guard let extesion = Bundle.main.infoDictionary?["NSExtension"] as? [String: String] else { return false }
        guard let widget = extesion["NSExtensionPointIdentifier"] else { return false }
        return widget == "com.apple.widgetkit-extension"
    }
    
    static func isInApp() -> Bool {
        return Bundle.main.bundleIdentifier == "com.arjundureja.SubscriberWidget"
    }
}
