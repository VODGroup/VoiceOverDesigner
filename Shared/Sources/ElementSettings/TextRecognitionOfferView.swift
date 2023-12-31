//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 30.12.2023.
//

import Foundation
import SwiftUI
import Purchases


public struct TextRecognitionOfferView: View {
    
    @Environment(\.unlocker) private var unlocker
    
    @State private var price: String?
    @State private var isLoading = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("Text recognition")
                    .font(.headline)
                
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
               
                
                Spacer()
                Button("Restore purchases", action: restoreButtonTapped)
                .buttonStyle(.borderless)
                .font(.headline)
            }
            
            Text("AI-power will recognize text for you, it's faster!")
            
            Button(action: purchaseButtonTapped, label: {
                Text(price.flatMap { "Purchase now for \($0)" } ?? "Purchase now")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            })
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(style: .init(lineWidth: 2))
                .fill(Color.purple)
        }
        .task {
            price = try? await unlocker?.fetchPrice()
        }
    }
    
    private func purchaseButtonTapped() {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                try await unlocker?.purchase()
            } catch {
                present(error)
            }
        }
    }
    
    private func restoreButtonTapped() {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            do {
                try await unlocker?.restore()
            } catch {
                present(error)
            }
        }
    }
    
    private func present(_ error: Error) {
#if os(macOS)
        let alert = NSAlert(error: error)
        alert.runModal()
#elseif os(iOS)
        // TODO: Show error
#endif
    }
}
