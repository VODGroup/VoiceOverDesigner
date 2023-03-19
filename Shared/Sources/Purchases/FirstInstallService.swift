import StoreKit

@available(macOS 13.0, *)
class FirstInstallService {
    
    func isGreatPersonWhoBoughtOurAppFirst() async throws -> Bool {
        if case .verified(let appTransaction) = try await AppTransaction.shared {
            return isPaidPurchase(originalAppVersion: appTransaction.originalAppVersion)
        } else {
            // Strange case.
            // The app doesn't know about their own install?
            // Probably, for ad-hoc versions
            return false
        }
    }
    
    func isPaidPurchase(originalAppVersion: String) -> Bool {
        originalAppVersion == "1.0"
    }
    
}
