//
//  HomeView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Search Icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Search Field
                TextField("Search or enter command...", text: $searchText)
                    .font(.system(size: 26, weight: .light)) // Modern thin font
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        // Handle command
                        handleCommand()
                    }
                    .onChange(of: searchText) { _, newValue in
                        // Real-time processing
                    }
                
                // Clear button
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Command hint
                if searchText.hasPrefix("/") {
                    Text("CMD")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial) // Frosted glass effect
            .cornerRadius(16) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }
        .padding(20) // Outer padding for shadow breathing room
        .frame(width: 750)
        .onAppear {
            isFocused = true
        }
    }
    
    private func handleCommand() {
        print("Command submitted: \(searchText)")
        // TODO: Implement command execution logic
    }
}

#Preview {
    HomeView()
        .frame(width: 800, height: 200)
        .background(Color.black)
}
