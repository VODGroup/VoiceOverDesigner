//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 24.09.2022.
//

import Foundation

class SettingsStorage {
    let userDefaults = UserDefaults.standard
    
    var isAutofillEnabled: Bool {
        set {
            userDefaults.set(newValue, forKey: UserDefaults.Key.isAutofillEnabled)
        }
        
        get {
            (userDefaults.value(forKey: UserDefaults.Key.isAutofillEnabled) as? Bool) ?? isAutofillEnabledDefault
        }
    }
    
    private var isAutofillEnabledDefault: Bool {
        true
    }
}

extension UserDefaults {
    typealias Key = String
}

extension UserDefaults.Key {
    static let isAutofillEnabled = "isAutofillEnabled"
}
