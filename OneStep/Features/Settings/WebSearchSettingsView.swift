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
            Picker("Default Search Engine", selection: $webService.selectedSearchEngine) {
                ForEach(SearchEngine.allCases) { engine in
                    Text(engine.rawValue).tag(engine)
                }
            }
            .pickerStyle(.menu)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bookmarks")
                    .font(.headline)
                
                if webService.bookmarks.isEmpty {
                    Text("No bookmarks added yet.")
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
                    .help("Add Bookmark")
                    
                    Button {
                        showingImporter = true
                    } label: {
                        Image(systemName: "arrow.up.document")
                    }
                    .buttonStyle(.plain)
                    .help("Import from HTML")
                    
                    Button {
                        exportBookmarks()
                    } label: {
                        Image(systemName: "arrow.down.document")
                    }
                    .buttonStyle(.plain)
                    .help("Export to HTML")
                    
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Reset to Default Bookmarks")
                    .confirmationDialog("Reset to Default?", isPresented: $showingResetConfirmation) {
                        Button("Reset", role: .destructive) {
                            withAnimation {
                                webService.resetBookmarksToDefault()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will replace all current bookmarks with the default list.")
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
                    .help("Clear All Bookmarks")
                    .confirmationDialog("Are you sure you want to clear all bookmarks?", isPresented: $showingClearConfirmation) {
                        Button("Clear All", role: .destructive) {
                            withAnimation {
                                webService.removeAllBookmarks()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                    
                    Divider()
                        .frame(height: 16)
                    
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.plain)
                    .help("How to export bookmarks")
                    .popover(isPresented: $showingHelp) {
                        BookmarkImportHelpView()
                    }
                }
                
                Text("You can use /web command to search your bookmarks quickly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showingAddBookmark) {
            VStack(spacing: 20) {
                Text("Add New Bookmark")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Title", text: $newBookmarkTitle)
                    TextField("URL", text: $newBookmarkURL)
                }
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        showingAddBookmark = false
                        newBookmarkTitle = ""
                        newBookmarkURL = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Add") {
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
                Text("Export Bookmarks Guide")
                    .font(.headline)
                Text("Follow these steps to export your bookmarks as an HTML file, then import it here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                browserGuide(name: "Safari", icon: "safari", steps: [
                    "File > Export Bookmarks...",
                    "Save the HTML file"
                ])
                
                browserGuide(name: "Google Chrome", icon: "globe", steps: [
                    "⋮ Menu > Bookmarks > Bookmark Manager",
                    "⋮ Menu (top right) > Export bookmarks",
                    "Save the HTML file"
                ])
                
                browserGuide(name: "Microsoft Edge", icon: "globe", steps: [
                    "Favorites (⭐️) > More options (…)",
                    "Export favorites",
                    "Save the HTML file"
                ])
                
                browserGuide(name: "Firefox", icon: "flame", steps: [
                    "Bookmarks > Manage Bookmarks",
                    "Import and Backup > Export Bookmarks to HTML...",
                    "Save the HTML file"
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
