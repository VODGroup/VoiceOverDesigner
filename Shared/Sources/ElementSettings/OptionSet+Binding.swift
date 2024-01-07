import Foundation
import SwiftUI

extension Binding where Value: OptionSet, Value == Value.Element {
    func contains(_ options: Value) -> Bool {
        return wrappedValue.contains(options)
    }

    func bind(
        _ options: Value
    ) -> Binding<Bool> {
        return .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            if newValue {
                self.wrappedValue.insert(options)
            } else {
                self.wrappedValue.remove(options)
            }
        }
    }
}

