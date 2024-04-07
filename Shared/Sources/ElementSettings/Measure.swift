import SwiftUI

struct Measure<Content: View>: View {
    @State var cost: TimeInterval = 0
    var content: Content
    let start = Date()
    init(@ViewBuilder builder: () -> Content) {
        // discard first time
        content = builder()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            self.content.onAppear {
                self.cost = Date().timeIntervalSince(start)
            }
            Text("\(Int(self.cost * 1000))ms")
                .font(.system(.caption, design: .monospaced))
                .padding(.vertical, 3)
                .padding(.horizontal, 5)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }
}

struct Measure_Previews: PreviewProvider {
    static var previews: some View {
        Measure {
            Text("Hello World")
        }
    }
}
