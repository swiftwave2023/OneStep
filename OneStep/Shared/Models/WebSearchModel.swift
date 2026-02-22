//
//  WebSearchModel.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import Foundation

struct WebBookmark: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String
    var url: String
    // Optional: Add icon or favicon URL if needed
    
    var faviconURL: URL? {
        // Using Google's favicon service which is generally reliable
        // Format: https://www.google.com/s2/favicons?sz=64&domain=example.com
        guard let host = URL(string: url)?.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(host)")
    }
    
    // Conformance to Hashable and Equatable is automatic for struct properties
}

enum SearchEngine: String, CaseIterable, Identifiable, Codable, Sendable {
    case google = "Google"
    case bing = "Bing"
    case baidu = "Baidu"
    case duckDuckGo = "DuckDuckGo"
    
    var id: String { rawValue }
    
    func searchURL(for query: String) -> URL? {
        // Encode query parameters safely
        let allowed = CharacterSet.urlQueryAllowed
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
        
        switch self {
        case .google:
            return URL(string: "https://www.google.com/search?q=\(encodedQuery)")
        case .bing:
            return URL(string: "https://www.bing.com/search?q=\(encodedQuery)")
        case .baidu:
            return URL(string: "https://www.baidu.com/s?wd=\(encodedQuery)")
        case .duckDuckGo:
            return URL(string: "https://duckduckgo.com/?q=\(encodedQuery)")
        }
    }
}
