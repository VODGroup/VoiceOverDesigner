import Foundation
import SwiftUI

private enum Flow {
    static func layout(sizes: [CGSize], spacing: CGFloat, containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (result, CGSize(width: maxX, height: currentPosition.y + lineHeight))
    }
}


struct FlowView<Element: Identifiable, Cell: View>: View {
    
    var elements: [Element]
    var cell: (Element) -> Cell
    var spacing: CGFloat
    
    init(elements: [Element], @ViewBuilder cell: @escaping (Element) -> Cell, spacing: CGFloat = 10) {
        self.elements = elements
        self.cell = cell
        self.spacing = spacing
    }
    
    @State private var sizes: [CGSize] = []
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
        let layout = Flow.layout(sizes: sizes,
                            spacing: spacing,
                            containerWidth: containerWidth).offsets
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { proxy in
                Color.clear.preference(key: TagSize.self, value: [proxy.size])
            }
            .onPreferenceChange(TagSize.self) {
                containerWidth = $0[0].width
            }
            .frame(height: 0)
            ZStack(alignment: .topLeading) {
                ForEach(Array(zip(elements, elements.indices)), id: \.0.id) { item, index in
                    cell(item)
                        .fixedSize()
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: TagSize.self, value: [proxy.size])
                        })
                        .alignmentGuide(.leading, computeValue: { dimension in
                            guard !layout.isEmpty else { return 0 }
                            return -layout[index].x
                        })
                        .alignmentGuide(.top, computeValue: { dimension in
                            guard !layout.isEmpty else { return 0 }
                            return -layout[index].y
                        })
                }
            }
            .onPreferenceChange(TagSize.self) {
                sizes = $0
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct TagSize: PreferenceKey {
    static var defaultValue: [CGSize] = []
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}


@available(iOS 16, macOS 13, *)
struct FlowLayout: Layout {
    
    let spacing: CGFloat
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return Flow.layout(sizes: sizes, spacing: spacing, containerWidth: containerWidth).size
         
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = Flow.layout(sizes: sizes, spacing: spacing, containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
}
