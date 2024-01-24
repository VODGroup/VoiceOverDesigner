import SwiftUI
import Artboard

struct HierarchicalElement: Identifiable { //Structure creating element (similarity of a binary tree node)
    var element: any ArtboardElement
    var indentationLevel: Int
    var isParent: Bool
    var id: UUID { element.id }
}

public struct NavigatorView: View {
    @ObservedObject var frame: Frame
    @State private var hierarchicalElements: [HierarchicalElement]

    public init(frame: Frame) {
        self.frame = frame
        _hierarchicalElements = State(initialValue: frame.elements.map {
            HierarchicalElement(element: $0, indentationLevel: 0, isParent: false)
        })
    }
    
    public var body: some View {
        Text(frame.label)
        List {
            ForEach($hierarchicalElements, id: \.element.id) { $element in
                HStack {
                    Image(systemName: element.isParent ? "folder" : "doc") // Images for creating hiererchy folders
                        .onTapGesture {
                            element.isParent.toggle()
                        }
                    Text(element.element.label)
                }
                .padding(.leading, CGFloat(element.indentationLevel * 20))
                .onDrag {
                    return NSItemProvider(object: String(element.id.uuidString) as NSString) //Data encapsulation
                }
            }
            .onMove(perform: move)
        }
        .toolbar {
            EditButton()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        hierarchicalElements.move(fromOffsets: source, toOffset: destination)

        updateIndentationLevels()
    }

    func updateIndentationLevels() {
        var currentIndentationLevel = 0
        var isPreviousElementParent = false

        for index in hierarchicalElements.indices {
            if isPreviousElementParent {
                currentIndentationLevel += 1
            } else {
                currentIndentationLevel = 0
            }

            hierarchicalElements[index].indentationLevel = currentIndentationLevel
            isPreviousElementParent = hierarchicalElements[index].isParent
        }
    }
}
    
