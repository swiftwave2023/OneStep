//
//  HomeView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI

struct SuggestionItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    static func == (lhs: SuggestionItem, rhs: SuggestionItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct HomeView: View {
    @State private var searchText = ""
    @State private var suggestions: [SuggestionItem] = []
    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool
    @Environment(\.openWindow) var openWindow
    
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
                        updateSuggestions()
                    }
                    .onKeyPress(.downArrow) {
                        moveSelection(down: true)
                        return .handled
                    }
                    .onKeyPress(.upArrow) {
                        moveSelection(down: false)
                        return .handled
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial) // Frosted glass effect
            .cornerRadius(16) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            
            // Suggestions List
            if !suggestions.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, item in
                            SuggestionRow(item: item, isSelected: index == selectedIndex)
                                .onTapGesture {
                                    item.action()
                                }
                        }
                    }
                }
                .frame(maxHeight: 300)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .padding(.top, 8)
            }
        }
        .padding(20) // Outer padding for shadow breathing room
        .frame(width: 750)
        .onAppear {
            isFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            isFocused = true
        }
    }
    
    private func updateSuggestions() {
        // Reset selection when search changes
        selectedIndex = 0
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("/") {
            // Command mode
            if "/settings".hasPrefix(trimmed) {
                suggestions = [
                    SuggestionItem(
                        icon: "gear",
                        title: "Open Settings",
                        subtitle: "Open the preferences window",
                        action: {
                            openSettings()
                            searchText = ""
                            WindowManager.shared.hideWindow()
                        }
                    )
                ]
            } else {
                suggestions = []
            }
        } else {
            // Normal search mode (can add more logic here)
            suggestions = []
        }
        
        // Notify WindowManager to resize (implementation detail left to WindowManager or GeometryReader)
    }
    
    private func moveSelection(down: Bool) {
        guard !suggestions.isEmpty else { return }
        
        if down {
            selectedIndex = min(selectedIndex + 1, suggestions.count - 1)
        } else {
            selectedIndex = max(selectedIndex - 1, 0)
        }
    }
    
    private func handleCommand() {
        if !suggestions.isEmpty {
            // Execute selected suggestion
            suggestions[selectedIndex].action()
        } else {
            print("Command submitted: \(searchText)")
            // Fallback for direct commands if any
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "/settings" {
                openSettings()
                searchText = ""
                WindowManager.shared.hideWindow()
            }
        }
    }
    
    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SuggestionRow: View {
    let item: SuggestionItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
                .foregroundColor(isSelected ? .white : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "return")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
        .padding(.horizontal, 4)
    }
}

#Preview {
    HomeView()
        .frame(width: 800, height: 200)
        .background(Color.black)
}
