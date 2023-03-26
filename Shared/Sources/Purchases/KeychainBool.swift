import Foundation
import Security

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
    
    func remove(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

extension Keychain {
    func readValue(for key: String) -> Bool? {
        guard let resultString: String = readValue(for: key) else { return nil }
        
        let resultBool = Bool(resultString)
        
        return resultBool
    }
    
    func save(_ value: Bool, for key: String) {
        let string = String(value)
        save(string, for: key)
    }
}
}
