import Foundation

public protocol SettingsStorageProtocol {
    var isAutofillEnabled: Bool { get set }
}

public class SettingsStorage: SettingsStorageProtocol {
    public init() {}
    
    let userDefaults = UserDefaults.standard
    
    public var isAutofillEnabled: Bool {
        set {
            userDefaults.set(newValue, forKey: UserDefaults.Key.isAutofillEnabled)
        }
        
        get {
            (userDefaults.value(forKey: UserDefaults.Key.isAutofillEnabled) as? Bool) ?? TextRecognitionService.isAutofillEnabledDefault()
        }
    }
}

extension UserDefaults {
    typealias Key = String
}

extension UserDefaults.Key {
    static let isAutofillEnabled = "isAutofillEnabled"
}
