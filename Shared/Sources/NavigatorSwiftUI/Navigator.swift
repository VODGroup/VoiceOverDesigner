import SwiftUI
import Artboard

public struct NavigatorView: View {
    
    @ObservedObject var frame: Frame
    
    public init(frame: Frame) {
        self.frame = frame
    }
    
    public var body: some View {
        Text(frame.label)
        List(frame.elements, id: \.id) { frame in
            Text(frame.label)
            // TODO: Add detalisation for elements inside frame
        }
    }
}
