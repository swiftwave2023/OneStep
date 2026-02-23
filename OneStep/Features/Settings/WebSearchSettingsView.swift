//
//  WebSearchSettingsView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct WebSearchSettingsView: View {
    @StateObject private var webService = WebSearchService.shared
    @State private var showingAddBookmark = false
    @State private var newBookmarkTitle = ""
    @State private var newBookmarkURL = ""
    @State private var showingImporter = false
    @State private var showingHelp = false
    @State private var showingClearConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var showingExporter = false
    @State private var bookmarkDocument: BookmarkDocument?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker(NSLocalizedString("Default Search Engine", comment: ""), selection: $webService.selectedSearchEngine) {
                ForEach(SearchEngine.allCases) { engine in
                    Text(engine.rawValue).tag(engine)
                }
            }
            .pickerStyle(.menu)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("Bookmarks", comment: ""))
                    .font(.headline)
                
                if webService.bookmarks.isEmpty {
                    Text(NSLocalizedString("No bookmarks added yet.", comment: ""))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    List {
                        ForEach(webService.bookmarks) { bookmark in
                            HStack {
                                if let favicon = bookmark.faviconURL {
                                    CachedAsyncImage(url: favicon) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Image(systemName: "safari")
                                            .foregroundStyle(.blue)
                                    }
                                    .frame(width: 16, height: 16)
                                } else {
                                    Image(systemName: "safari")
                                        .foregroundStyle(.blue)
                                        .frame(width: 16, height: 16)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bookmark.title)
                                        .font(.system(size: 13, weight: .medium))
                                        .lineLimit(1)
                                    Text(bookmark.url)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        webService.removeBookmark(id: bookmark.id)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                        .onMove { source, destination in
                            webService.moveBookmark(from: source, to: destination)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 450)
                    .listStyle(.plain)
                }
                
                HStack {
                    Button {
                        showingAddBookmark = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                    .help(NSLocalizedString("Add Bookmark", comment: ""))
                    
                    Button {
                        showingImporter = true
                    } label: {
                        Image(systemName: "arrow.up.document")
                    }
                    .buttonStyle(.plain)
                    .help(NSLocalizedString("Import from HTML", comment: ""))
                    
                    Button {
                        exportBookmarks()
                    } label: {
                        Image(systemName: "arrow.down.document")
                    }
                    .buttonStyle(.plain)
                    .help(NSLocalizedString("Export to HTML", comment: ""))
                    
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help(NSLocalizedString("Reset to Default Bookmarks", comment: ""))
                    .confirmationDialog(NSLocalizedString("Reset to Default?", comment: ""), isPresented: $showingResetConfirmation) {
                        Button(NSLocalizedString("Reset", comment: ""), role: .destructive) {
                            withAnimation {
                                webService.resetBookmarksToDefault()
                            }
                        }
                        Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
                    } message: {
                        Text(NSLocalizedString("This will replace all current bookmarks with the default list.", comment: ""))
                    }
                    
                    Spacer()
                    
                    Button {
                        showingClearConfirmation = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .disabled(webService.bookmarks.isEmpty)
                    .help(NSLocalizedString("Clear All Bookmarks", comment: ""))
                    .confirmationDialog(NSLocalizedString("Are you sure you want to clear all bookmarks?", comment: ""), isPresented: $showingClearConfirmation) {
                        Button(NSLocalizedString("Clear All", comment: ""), role: .destructive) {
                            withAnimation {
                                webService.removeAllBookmarks()
                            }
                        }
                        Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
                    } message: {
                        Text(NSLocalizedString("This action cannot be undone.", comment: ""))
                    }
                    
                    Divider()
                        .frame(height: 16)
                    
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.plain)
                    .help(NSLocalizedString("How to export bookmarks", comment: ""))
                    .popover(isPresented: $showingHelp) {
                        BookmarkImportHelpView()
                    }
                }
                
                Text(NSLocalizedString("You can use /web command to search your bookmarks quickly.", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .navigationTitle(NSLocalizedString("Web Search", comment: ""))
        .sheet(isPresented: $showingAddBookmark) {
            VStack(spacing: 20) {
                Text(NSLocalizedString("Add New Bookmark", comment: ""))
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField(NSLocalizedString("Title", comment: ""), text: $newBookmarkTitle)
                    TextField(NSLocalizedString("URL", comment: ""), text: $newBookmarkURL)
                }
                
                HStack(spacing: 12) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        showingAddBookmark = false
                        newBookmarkTitle = ""
                        newBookmarkURL = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button(NSLocalizedString("Add", comment: "")) {
                        if !newBookmarkTitle.isEmpty && !newBookmarkURL.isEmpty {
                            webService.addBookmark(title: newBookmarkTitle, url: newBookmarkURL)
                            newBookmarkTitle = ""
                            newBookmarkURL = ""
                            showingAddBookmark = false
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(newBookmarkTitle.isEmpty || newBookmarkURL.isEmpty)
                }
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.html], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        try webService.importBookmarks(from: url)
                    } catch {
                        // Handle error (e.g. show alert)
                        print("Import failed: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
        .fileExporter(isPresented: $showingExporter, document: bookmarkDocument, contentType: .html, defaultFilename: "bookmarks.html") { result in
            switch result {
            case .success(let url):
                print("Exported to \(url)")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func exportBookmarks() {
        let html = webService.exportBookmarks()
        bookmarkDocument = BookmarkDocument(htmlContent: html)
        showingExporter = true
    }
}

struct BookmarkDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.html] }
    
    var htmlContent: String
    
    init(htmlContent: String) {
        self.htmlContent = htmlContent
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            htmlContent = String(decoding: data, as: UTF8.self)
        } else {
            htmlContent = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = htmlContent.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

struct BookmarkImportHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("Export Bookmarks Guide", comment: ""))
                    .font(.headline)
                Text(NSLocalizedString("Follow these steps to export your bookmarks as an HTML file, then import it here.", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                browserGuide(name: "Safari", icon: "safari", steps: [
                    NSLocalizedString("File > Export Bookmarks...", comment: ""),
                    NSLocalizedString("Save the HTML file", comment: "")
                ])
                
                browserGuide(name: "Google Chrome", icon: "globe", steps: [
                    NSLocalizedString("⋮ Menu > Bookmarks > Bookmark Manager", comment: ""),
                    NSLocalizedString("⋮ Menu (top right) > Export bookmarks", comment: ""),
                    NSLocalizedString("Save the HTML file", comment: "")
                ])
                
                browserGuide(name: "Microsoft Edge", icon: "globe", steps: [
                    NSLocalizedString("Favorites (⭐️) > More options (…)", comment: ""),
                    NSLocalizedString("Export favorites", comment: ""),
                    NSLocalizedString("Save the HTML file", comment: "")
                ])
                
                browserGuide(name: "Firefox", icon: "flame", steps: [
                    NSLocalizedString("Bookmarks > Manage Bookmarks", comment: ""),
                    NSLocalizedString("Import and Backup > Export Bookmarks to HTML...", comment: ""),
                    NSLocalizedString("Save the HTML file", comment: "")
                ])
            }
        }
        .padding()
        .frame(width: 320)
    }
    
    private func browserGuide(name: String, icon: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                Text(name)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 4) {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                    Text(step)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .padding(.leading, 8)
            }
        }
    }
}

#Preview {
    WebSearchSettingsView()
}
