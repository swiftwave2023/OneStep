//
//  HomeView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
import AppKit

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
    var fileURL: URL? = nil
    
    static func == (lhs: SuggestionItem, rhs: SuggestionItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct HomeView: View {
    @StateObject private var appManager = AppManager.shared
    @StateObject private var fileSearchService = FileSearchService.shared
    @State private var searchText = ""
    @State private var suggestions: [SuggestionItem] = []
    @State private var selectedIndex: Int = 0
    @State private var selectedCommand: SuggestionItem?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            searchBarView
            
            if !searchText.isEmpty || selectedCommand != nil {
                Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 8)
            }
            
            contentView
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
    
    // MARK: - Subviews
    
    private var searchBarView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
                
                if let command = selectedCommand {
                    commandBadge(command)
                }
                
                searchTextField
                
                if !searchText.isEmpty || selectedCommand != nil {
                    clearButton
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }
    
    private func commandBadge(_ command: SuggestionItem) -> some View {
        HStack(spacing: 4) {
            switch command.icon {
            case .system(let name):
                Image(systemName: name)
                    .font(.system(size: 12))
            case .image(let nsImage):
                Image(nsImage: nsImage)
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            Text(command.title)
                .font(.system(size: 13, weight: .medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var searchTextField: some View {
        TextField(selectedCommand == nil ? "Search or type / for commands…" : "Search apps...", text: $searchText)
            .font(.system(size: 26, weight: .light))
            .textFieldStyle(.plain)
            .focused($isFocused)
            .id("search_field")
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
            .background(
                DeleteKeyMonitor {
                    if searchText.isEmpty && selectedCommand != nil {
                        selectedCommand = nil
                        updateSuggestions()
                        return true
                    }
                    return false
                }
            )
    }
    
    private var clearButton: some View {
        Button {
            searchText = ""
            selectedCommand = nil
            updateSuggestions()
        } label: {
            Image(systemName: "xmark.circle.fill")
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
    
    private var contentView: some View {
        Group {
            if selectedCommand?.title == "/apps" {
                appsGridView
            } else if selectedCommand?.title == "/files" && searchText.isEmpty {
                fileSearchPromptView
            } else if !searchText.isEmpty {
                suggestionsListView
            }
        }
    }
    
    private var appsGridView: some View {
        let appsToShow = getFilteredApps()
        return Group {
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
        }
    }
    
    private var fileSearchPromptView: some View {
        VStack(spacing: 6) {
            Image(systemName: "doc.magnifyingglass")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("Type to search files")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var suggestionsListView: some View {
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
    
    private func updateSuggestions() {
        // Reset selection when search changes
        selectedIndex = 0
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let command = selectedCommand {
            if command.title == "/apps" {
                 suggestions = [] // Grid view handles this
            } else if command.title == "/files" {
                // File search
                let files = fileSearchService.search(text: trimmed)
                suggestions = files.map { file in
                    SuggestionItem(
                        icon: .image(NSWorkspace.shared.icon(forFile: file.path)),
                        title: file.name,
                        subtitle: file.path,
                        action: {
                            fileSearchService.openFile(file.path)
                            searchText = ""
                            WindowManager.shared.hideWindow()
                        },
                        fileURL: URL(fileURLWithPath: file.path)
                    )
                }
            }
        } else {
            if trimmed.hasPrefix("/") {
                suggestions = commandSuggestions(matching: trimmed)
            } else {
                // App search
                let apps = appManager.search(text: trimmed)
                let appItems = apps.map { app in
                    SuggestionItem(
                        icon: .image(NSWorkspace.shared.icon(forFile: app.path)),
                        title: app.name,
                        subtitle: app.path,
                        action: {
                            appManager.launchApp(app)
                            searchText = ""
                            WindowManager.shared.hideWindow()
                        },
                        fileURL: URL(fileURLWithPath: app.path)
                    )
                }
                
                // File search
                let files = fileSearchService.search(text: trimmed)
                let fileItems = files.map { file in
                    SuggestionItem(
                        icon: .image(NSWorkspace.shared.icon(forFile: file.path)),
                        title: file.name,
                        subtitle: file.path,
                        action: {
                            fileSearchService.openFile(file.path)
                            searchText = ""
                            WindowManager.shared.hideWindow()
                        },
                        fileURL: URL(fileURLWithPath: file.path)
                    )
                }
                
                suggestions = appItems + fileItems
            }
        }
        
        // Notify WindowManager to resize (implementation detail left to WindowManager or GeometryReader)
    }
    
    private func commandSuggestions(matching input: String) -> [SuggestionItem] {
        let all: [SuggestionItem] = [
            SuggestionItem(
                icon: .system("square.grid.2x2"),
                title: "/apps",
                subtitle: "Show all apps",
                action: {
                    selectCommand(title: "/apps")
                }
            ),
            SuggestionItem(
                icon: .system("folder"),
                title: "/files",
                subtitle: "Search files",
                action: {
                    selectCommand(title: "/files")
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
    
    private func selectCommand(title: String) {
        // Find the command item from a fresh list to ensure we have the correct data
        // Ideally we should have a static list or a way to get the item without recreating everything
        // But for now, we can just recreate the item or search in the list returned by commandSuggestions("/")
        if let cmd = commandSuggestions(matching: "/").first(where: { $0.title == title }) {
             selectedCommand = cmd
             searchText = ""
             updateSuggestions()
        }
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
        // If selectedCommand is /apps, we filter by searchText
        if selectedCommand?.title == "/apps" {
            return trimmed.isEmpty ? appManager.apps : appManager.search(text: trimmed)
        }
        return []
    }
    
    private func handleCommand() {
        if selectedCommand?.title == "/apps" {
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
            } else if command == "/apps" {
                 selectCommand(title: "/apps")
            } else if command == "/files" {
                selectCommand(title: "/files")
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
