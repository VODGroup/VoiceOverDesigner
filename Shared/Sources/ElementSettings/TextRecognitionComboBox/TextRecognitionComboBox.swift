//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 28.10.2023.
//

import Foundation
import SwiftUI

struct TextRecognitionComboBoxView: View {
    @Binding var text: String
    
    var variants = ["Small", "Medium", "Large"]
    
    var joinedVariants: String {
        variants.joined(separator: " ")
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            TextField("Value", text: $text)
                .labelsHidden()
                .textFieldStyle(.roundedBorder)
                .lineLimit(5)
                .modify({ picker in
                    if #available(iOS 17.0, macOS 14.0, *) {
                        picker.controlSize(.extraLarge)
                    } else {
                        picker.controlSize(.large)
                    }
                })
            
            Menu {
                ForEach(variants, id: \.self) { variant in
                    Button(variant) {
                        animateTyping(variant)
                    }
                }
                Button(joinedVariants, systemImage: "text.quote") {
                    animateTyping(joinedVariants)
                }
            } label: {
                Image(systemName: "text.viewfinder")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .purple)
            }
            .buttonStyle(.borderless)
            .disabled(variants.isEmpty)
        }
    }
    
    func animateTyping(_ text: String) {
        self.text = ""
        text.enumerated().forEach { index, character in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.01) {
                self.text += String(character)
            }
        }
    }
}
