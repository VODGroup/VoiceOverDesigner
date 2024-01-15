import SwiftUI
import Artboard

public struct NavigatorView: View {
    
    @State var artboard: Artboard
    
    public init(artboard: Artboard) {
        self.artboard = artboard
    }
    
    public var body: some View {
        List(artboard.frames, id: \.id) { frame in
            Text(frame.label)
            // TODO: Add detalisation for elements inside frame
        }
    }
}
