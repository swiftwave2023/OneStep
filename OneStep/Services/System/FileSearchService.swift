import SwiftUI
internal import Combine
import Defaults

// MARK: - Defaults Keys
extension Defaults.Keys {
    static let fileSearchScopes = Key<[SearchScope]>("fileSearchScopesV2", default: [])
}

struct FileItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    let path: String
    
    // Cache for search
    let pinyin: String
    let initials: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class FileSearchService: ObservableObject {
    static let shared = FileSearchService()
    
    @Published var files: [FileItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Observe changes to search scopes and re-index
        Defaults.publisher(.fileSearchScopes)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshIndex()
            }
            .store(in: &cancellables)
        
        // Initial index
        refreshIndex()
    }
    
    func refreshIndex() {
        let scopes = Defaults[.fileSearchScopes]
        Task.detached(priority: .userInitiated) {
            let items = self.scanFiles(in: scopes)
            await MainActor.run {
                self.files = items
            }
        }
    }
    
    nonisolated private func scanFiles(in scopes: [SearchScope]) -> [FileItem] {
        var foundFiles: [FileItem] = []
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
        
        for scope in scopes {
            // Resolve URL (potentially with security scope)
            guard let url = scope.resolvedURL() else { continue }
            
            // Start accessing security scoped resource
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Check if scope exists
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue else { continue }
            
            // Create enumerator
            if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: options) {
                for case let fileURL as URL in enumerator {
                    // We only want files, not directories (unless specified otherwise, but for now files)
                    // Also maybe limit depth or count if too many?
                    // For now, let's just get all files.
                    
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                        if resourceValues.isRegularFile == true {
                            if let item = self.processFile(at: fileURL) {
                                foundFiles.append(item)
                            }
                        }
                    } catch {
                        continue
                    }
                }
            }
        }
        return foundFiles
    }
    
    nonisolated private func processFile(at url: URL) -> FileItem? {
        let name = url.lastPathComponent
        let path = url.path
        
        // Generate Pinyin
        let pinyin = name.toPinyin()
        let initials = name.toPinyinInitials()
        
        return FileItem(name: name, path: path, pinyin: pinyin, initials: initials)
    }
    
    func search(text: String) -> [FileItem] {
        guard !text.isEmpty else { return [] }
        let lowerText = text.lowercased()
        
        return files.filter { file in
            file.name.lowercased().contains(lowerText) ||
            file.pinyin.contains(lowerText) ||
            file.initials.contains(lowerText)
        }
    }
    
    func addScope(url: URL) {
        var scopes = Defaults[.fileSearchScopes]
        // Check if already exists
        if scopes.contains(where: { $0.url.path == url.path }) {
            return
        }
        
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            let scope = SearchScope(url: url, bookmarkData: bookmarkData)
            scopes.append(scope)
            Defaults[.fileSearchScopes] = scopes
        } catch {
            print("Failed to create bookmark for \(url): \(error)")
            // Fallback: add without bookmark
            let scope = SearchScope(url: url)
            scopes.append(scope)
            Defaults[.fileSearchScopes] = scopes
        }
    }
    
    func removeScope(url: URL) {
        var scopes = Defaults[.fileSearchScopes]
        scopes.removeAll { $0.url.path == url.path }
        Defaults[.fileSearchScopes] = scopes
    }
    
    func openFile(_ path: String) {
        let fileURL = URL(fileURLWithPath: path)
        let scopes = Defaults[.fileSearchScopes]
        
        // Find the scope that contains this file
        if let scope = scopes.first(where: { path.hasPrefix($0.url.path) }) {
            // Resolve bookmark to ensure we have access
            if let resolvedURL = scope.resolvedURL() {
                let accessing = resolvedURL.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        resolvedURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                // Open the file
                NSWorkspace.shared.open(fileURL)
                return
            }
        }
        
        // Fallback
        NSWorkspace.shared.open(fileURL)
    }
}
