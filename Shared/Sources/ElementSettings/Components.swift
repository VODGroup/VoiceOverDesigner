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
    @State private var isConfirmationDialogPresented = false
    var dismiss: DismissAction
    var delete: () -> Void
    
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
    
    @ToolbarContentBuilder
    private var deleteToolbarItem: some ToolbarContent {
        
        let placement: ToolbarItemPlacement = {
            #if os(iOS)
            return .bottomBar
            #elseif os(macOS)
            return .primaryAction
            #endif
        }()
        
        ToolbarItem(placement: placement, content: {
            Button(role: .destructive, action: presentDialog, label: {
                Image(systemName: "trash")
                    .accessibilityLabel(Text("Delete"))
            })
            .font(.title3)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .confirmationDialog("This control will be deleted from document",
                                isPresented: $isConfirmationDialogPresented,
                                titleVisibility: .visible,
                                actions: confirmationDialogs)
        })
    }
    
    private func presentDialog() {
        isConfirmationDialogPresented = true
    }
    
    private func dismissDialog() {
        isConfirmationDialogPresented = false
    }
    
    @ViewBuilder
    private func confirmationDialogs() -> some View {
        Button(role: .destructive, action: delete, label: {Text("Delete")})
        Button(role: .cancel, action: dismissDialog, label: {Text("Cancel")})
    }
}
