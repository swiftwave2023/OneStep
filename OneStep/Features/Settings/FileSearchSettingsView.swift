//
//  FileSearchSettingsView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI
import Defaults

struct FileSearchSettingsView: View {
    @Default(.fileSearchScopes) var scopes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("File Search Scopes", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("Add folders to include in file search results (use /files command).", comment: ""))
                .foregroundStyle(.secondary)
            
            List {
                ForEach(scopes) { scope in
                    let url = scope.url
                    HStack {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text(url.lastPathComponent)
                                .fontWeight(.medium)
                            Text(url.path)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            removeScope(scope)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .frame(minHeight: 200)
            .overlay(
                Group {
                    if scopes.isEmpty {
                        ContentUnavailableView(NSLocalizedString("No Search Scopes", comment: ""), systemImage: "folder.badge.plus", description: Text(NSLocalizedString("Add folders to start searching files.", comment: "")))
                    }
                }
            )
            
            HStack {
                Button {
                    addScope()
                } label: {
                    Label(NSLocalizedString("Add Folder", comment: ""), systemImage: "plus")
                }
                
                Spacer()
                
                Button(NSLocalizedString("Reset to Defaults", comment: "")) {
                    Defaults.reset(.fileSearchScopes)
                }
                .disabled(scopes.isEmpty)
            }
        }
        .padding()
    }
    
    private func addScope() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.prompt = NSLocalizedString("Add Search Scope", comment: "")
        
        panel.begin { response in
            if response == .OK {
                for url in panel.urls {
                    // Check if already exists
                    if scopes.contains(where: { $0.url.path == url.path }) {
                        continue
                    }
                    
                    do {
                        let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                        let scope = SearchScope(url: url, bookmarkData: bookmarkData)
                        scopes.append(scope)
                    } catch {
                        print("Failed to create bookmark for \(url): \(error)")
                        // Fallback: add without bookmark
                        let scope = SearchScope(url: url)
                        scopes.append(scope)
                    }
                }
            }
        }
    }
    
    private func removeScope(_ scope: SearchScope) {
        scopes.removeAll { $0.id == scope.id }
    }
}

#Preview {
    FileSearchSettingsView()
}
