//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 18.01.2023.
//

import SwiftUI


struct SectionTitle: View {
    
    let title: LocalizedStringKey
    
    init(_ title: LocalizedStringKey) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.headline)
    }
}

struct TextValue: View {
    
    let title: LocalizedStringKey
    @Binding var value: String
    
    
    public var body: some View {
        Section(content: {
            TextField(title, text: $value)
        }, header: {
            SectionTitle(title)
        })
    }
}


struct EditorToolbar: ToolbarContent {
    var dismiss: DismissAction
    var deleteTappedAction: () -> Void
    
    var body: some ToolbarContent {
        closeToolbarItem
        doneToolbarItem
        deleteToolbarItem
    }
    
    private var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction, content: {
            Button(action: dismiss.callAsFunction, label: {
                Text("Close")
            })
        })
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction, content: {
            Button(action: dismiss.callAsFunction, label: {
                Text("Done")
            })
        })
    }
    
    private var deleteToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .bottomBar, content: {
            Button(role: .destructive, action: deleteTappedAction, label: {
                Image(systemName: "trash")
                    .accessibilityLabel(Text("Delete"))
            })
            .font(.title3)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .trailing)
        })
    }
}