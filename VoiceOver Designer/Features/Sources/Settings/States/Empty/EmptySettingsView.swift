//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 29.10.2023.
//

import Foundation
import SwiftUI


struct EmptySettingsView: View {
    var body: some View {
        Text("Select or draw a control\nto adjust settings")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .foregroundStyle(.quaternary)
    }
}
