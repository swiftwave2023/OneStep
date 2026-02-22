//
//  HomeView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI

enum SuggestionIcon: Equatable {
    case system(String)
    case image(NSImage)
    
    static func == (lhs: SuggestionIcon, rhs: SuggestionIcon) -> Bool {
        switch (lhs, rhs) {
        case (.system(let l), .system(let r)): return l == r
        case (.image(let l), .image(let r)): return l === r
        default: return false
        }
    }
}

struct SuggestionItem: Identifiable, Equatable {
    let id = UUID()
    let icon: SuggestionIcon
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    static func == (lhs: SuggestionItem, rhs: SuggestionItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct HomeView: View {
    @StateObject private var appManager = AppManager.shared
    @State private var searchText = ""
    @State private var suggestions: [SuggestionItem] = []
    @State private var selectedIndex: Int = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("Search or type / for commands…", text: $searchText)
                        .font(.system(size: 26, weight: .light))
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .onSubmit {
                            handleCommand()
                        }
                        .onKeyPress(.return) {
                            handleCommand()
                            return .handled
                        }
                        .onChange(of: searchText) { _, _ in
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
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            updateSuggestions()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            
            if !searchText.isEmpty {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
            }
            
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("/apps") {
                    let appsToShow = getFilteredApps()
                    
                    if appsToShow.isEmpty {
                         VStack(spacing: 6) {
                            Text("No matching apps")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        AppGridView(apps: appsToShow) { app in
                            appManager.launchApp(app)
                            searchText = ""
                            WindowManager.shared.hideWindow()
                        }
                    }
                } else {
                    VStack(spacing: 0) {
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
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                            }
                            .frame(maxHeight: 360)
                        } else {
                            let isCommand = searchText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("/")
                            VStack(spacing: 6) {
                                Text(isCommand ? "No matching commands" : "No results")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text(isCommand ? "Type / to see available commands" : "Try different keywords or type / for commands")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .frame(width: 780)
        .onAppear { isFocused = true }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            isFocused = true
        }
    }
    
    private func updateSuggestions() {
        // Reset selection when search changes
        selectedIndex = 0
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("/apps") {
            suggestions = [] // Grid view handles this
        } else if trimmed.hasPrefix("/") {
            suggestions = commandSuggestions(matching: trimmed)
        } else {
            // App search
            let apps = appManager.search(text: trimmed)
            suggestions = apps.map { app in
                SuggestionItem(
                    icon: .image(app.icon),
                    title: app.name,
                    subtitle: app.path,
                    action: {
                        appManager.launchApp(app)
                        searchText = ""
                        WindowManager.shared.hideWindow()
                    }
                )
            }
        }
        
        // Notify WindowManager to resize (implementation detail left to WindowManager or GeometryReader)
    }
    
    private func commandSuggestions(matching input: String) -> [SuggestionItem] {
        var all: [SuggestionItem] = [
            SuggestionItem(
                icon: .system("square.grid.2x2"),
                title: "/apps",
                subtitle: "Show all apps",
                action: {
                    searchText = "/apps"
                    updateSuggestions()
                }
            ),
            SuggestionItem(
                icon: .system("gearshape"),
                title: "/settings",
                subtitle: "Open Settings",
                action: {
                    openSettings()
                    searchText = ""
                    WindowManager.shared.hideWindow()
                }
            ),
            SuggestionItem(
                icon: .system("power"),
                title: "/quit",
                subtitle: "Quit OneStep",
                action: {
                    NSApplication.shared.terminate(nil)
                }
            )
        ]
        
        if input == "/" {
            return all
        }
        return all.filter { $0.title.hasPrefix(input) }
    }
    
    private func moveSelection(down: Bool) {
        guard !suggestions.isEmpty else { return }
        
        if down {
            selectedIndex = min(selectedIndex + 1, suggestions.count - 1)
        } else {
            selectedIndex = max(selectedIndex - 1, 0)
        }
    }
    
    private func getFilteredApps() -> [AppItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("/apps") else { return [] }
        
        let query = trimmed.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? appManager.apps : appManager.search(text: query)
    }
    
    private func handleCommand() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("/apps") {
            let apps = getFilteredApps()
            if apps.count == 1 {
                appManager.launchApp(apps[0])
                searchText = ""
                WindowManager.shared.hideWindow()
            }
            return
        }
        
        if !suggestions.isEmpty {
            // Execute selected suggestion
            suggestions[selectedIndex].action()
        } else {
            print("Command submitted: \(searchText)")
            // Fallback for direct commands if any
            let command = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if command == "/settings" {
                openSettings()
                searchText = ""
                WindowManager.shared.hideWindow()
            } else if command == "/quit" {
                NSApplication.shared.terminate(nil)
            }
        }
    }
    
    @MainActor private func openSettings() {
        SettingsWindowController.shared.show()
    }
}

struct SuggestionRow: View {
    let item: SuggestionItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            switch item.icon {
            case .system(let name):
                Image(systemName: name)
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .white : .secondary)
            case .image(let nsImage):
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
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
        .frame(width: 820, height: 520)
        .background(Color.clear)
}
