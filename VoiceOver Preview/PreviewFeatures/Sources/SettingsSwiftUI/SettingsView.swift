import SwiftUI

public struct SettingsView: View {
    
    public init() {}
    
    @State private var label: String = "Element's label"
    @State private var value: String = ""
    @State private var hint: String = ""
    
    @State private var isOn: Bool = false
    
    private var traits = ["Button", "Header", "Image", "Link", "Static text", "Search field"]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(label)
                .font(.largeTitle)
            
            TextValue(title: "Label", value: $label)
            TextValue(title: "Value", value: $value)
            
            VStack(alignment: .leading) {
                SectionTitle("Traits")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(traits, id: \.self) { trait in
                            Button(trait) {
                                // TODO: Add action
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                        }
                    }
                }.frame(height: 40)
            }
            
            VStack(alignment: .leading) {
                SectionTitle("Custom actions")
                
                Button("+ Add custom action") {
                    // TODO: Add action
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
            
            VStack(alignment: .leading) {
                SectionTitle("Custom description")
                
                Button("+ Add custom description") {
                    // TODO: Add action
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hint")
                    .font(.headline)
                
                TextField("Hint", text: $hint)
                    .textFieldStyle(.roundedBorder)
            }
            
            Spacer()
        }.padding()
        
    }
}

struct SectionTitle: View {
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TextValue: View {
    
    let title: String
    @Binding var value: String
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            SectionTitle(title)
            
            TextField(title, text: $value)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
