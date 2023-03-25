import Foundation
import Security

@propertyWrapper
struct KeychainBool {
    let key: String
    let defaultValue: Bool
    
    init(key: String, defaultValue: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    private let keychain = Keychain()
    
    var wrappedValue: Bool {
        get {
            return readValue() ?? defaultValue
        }
        set {
            saveValue(newValue)
        }
    }
    
    func readValue() -> Bool? {
        guard let resultString = keychain.readValue(for: key) else { return nil }
        
        let resultBool = Bool(resultString)
        
        return resultBool
    }
    
    func saveValue(_ value: Bool) {
        let string = String(value)
        keychain.save(string, for: key)
    }
}

class Keychain {
    func readValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let existingItem = item as? [String: Any],
              let valueData = existingItem[kSecValueData as String] as? Data,
              let resultString = String(data: valueData, encoding: .utf8)
        else {
            return nil
        }
        
        return resultString
    }
    
    func save(_ value: String, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
