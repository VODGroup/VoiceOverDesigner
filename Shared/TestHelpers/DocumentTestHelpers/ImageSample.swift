import Foundation
import Document

public class ImageSample {
    
    public init() {}
    
    public func image(name: String) -> Image? {
#if os(macOS)
        return Bundle.module.image(forResource: name)
#elseif os(iOS)
        return Image(named: name, in: Bundle.module, with: nil)
#endif
    }
}
