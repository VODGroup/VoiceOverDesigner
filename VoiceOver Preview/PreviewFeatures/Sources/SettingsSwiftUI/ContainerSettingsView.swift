import Document
import SwiftUI


public struct ContainerSettingsView: View {
    @ObservedObject var container: A11yContainer
    
    public init(container: A11yContainer) {
        self.container = container
    }
    
    public var body: some View {
        NavigationView {
            List {
                labelField
                containerTypePicker
                navigationStylePicker
                optionsView
            }
            .navigationTitle(container.label)
        }
        .navigationViewStyle(.stack)


    }
    
    private var containerTypePicker: some View {
        Picker("Type", selection: $container.containerType, content: {
            ForEach(A11yContainer.ContainerType.allCases) { type in
                Text(type.rawValue)
                    .tag(type)
            }
        })
        
        
    }
    
    private var navigationStylePicker: some View {
        Picker("Navigation Style", selection: $container.navigationStyle, content: {
            ForEach(A11yContainer.NavigationStyle.allCases) { style in
                Text(style.rawValue)
                    .tag(style)
            }
        })
    }
    
    private var optionsView: some View {
        Section(content: {
            Toggle("Modal view", isOn: $container.isModal)
            Toggle("Tab Section", isOn: $container.isTabTrait)
            Toggle("Enumerate elements", isOn: $container.isEnumerated)
        }, header: {
            Text("Options")
        })
    }
    
    private var labelField: some View {
        TextField("Label", text: $container.label)
    }
}

struct ContainerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerSettingsView(container: .init(elements: [], frame: .zero, label: "er"))
    }
}

