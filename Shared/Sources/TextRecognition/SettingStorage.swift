import Foundation
import Document

public protocol SettingsStorageProtocol {
    var isAutofillEnabled: Bool { get set }
}

public class SettingsStorage: SettingsStorageProtocol {
    public init() {}
    
    let userDefaults = UserDefaults.standard
    
    @Storage(key: "isAutofillEnabled", defaultValue: TextRecognitionService.isAutofillEnabledDefault())
    public var isAutofillEnabled: Bool
}
