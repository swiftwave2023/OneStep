
import Foundation
import Defaults

struct SearchScope: Identifiable, Codable, Hashable, Sendable, Defaults.Serializable {
    var id: UUID = UUID()
    var url: URL
    var bookmarkData: Data?
    
    // Resolve URL with security scope if bookmark exists
    nonisolated func resolvedURL() -> URL? {
        guard let data = bookmarkData else { return url }
        var isStale = false
        // Try to resolve the bookmark
        if let resolved = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
            return resolved
        }
        return url // Fallback to original if bookmark fails
    }
}
