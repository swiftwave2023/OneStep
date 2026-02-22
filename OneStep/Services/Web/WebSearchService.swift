//
//  WebSearchService.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import Foundation
import SwiftUI
internal import Combine

class WebSearchService: ObservableObject {
    static let shared = WebSearchService()
    
    // MARK: - Published Properties
    @Published var bookmarks: [WebBookmark] = []
    @Published var selectedSearchEngine: SearchEngine = .google {
        didSet {
            UserDefaults.standard.set(selectedSearchEngine.rawValue, forKey: "defaultSearchEngine")
        }
    }
    
    // MARK: - Private Properties
    private let bookmarksKey = "userBookmarks"
    
    // MARK: - Initialization
    private init() {
        loadSettings()
        loadBookmarks()
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        if let savedEngine = UserDefaults.standard.string(forKey: "defaultSearchEngine"),
           let engine = SearchEngine(rawValue: savedEngine) {
            selectedSearchEngine = engine
        }
    }
    
    // MARK: - Bookmark Management
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([WebBookmark].self, from: data) {
            bookmarks = decoded
        } else {
            // Load default bookmarks if empty
            loadDefaultBookmarks()
        }
    }
    
    private func loadDefaultBookmarks() {
        let defaults: [WebBookmark]
        
        // Detect system language
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        if languageCode.starts(with: "zh") {
            // Chinese Defaults (Top 20)
            defaults = [
                WebBookmark(title: "百度", url: "https://www.baidu.com"),
                WebBookmark(title: "哔哩哔哩", url: "https://www.bilibili.com"),
                WebBookmark(title: "知乎", url: "https://www.zhihu.com"),
                WebBookmark(title: "微博", url: "https://weibo.com"),
                WebBookmark(title: "淘宝", url: "https://www.taobao.com"),
                WebBookmark(title: "京东", url: "https://www.jd.com"),
                WebBookmark(title: "抖音", url: "https://www.douyin.com"),
                WebBookmark(title: "GitHub", url: "https://github.com"),
                WebBookmark(title: "CSDN", url: "https://www.csdn.net"),
                WebBookmark(title: "掘金", url: "https://juejin.cn"),
                WebBookmark(title: "V2EX", url: "https://www.v2ex.com"),
                WebBookmark(title: "Google", url: "https://www.google.com"),
                WebBookmark(title: "Stack Overflow", url: "https://stackoverflow.com"),
                WebBookmark(title: "码云", url: "https://gitee.com"),
                WebBookmark(title: "腾讯视频", url: "https://v.qq.com"),
                WebBookmark(title: "爱奇艺", url: "https://www.iqiyi.com"),
                WebBookmark(title: "高德地图", url: "https://www.amap.com"),
                WebBookmark(title: "百度贴吧", url: "https://tieba.baidu.com"),
                WebBookmark(title: "小红书", url: "https://www.xiaohongshu.com/explore"),
                WebBookmark(title: "Apple", url: "https://www.apple.com.cn")
            ]
        } else {
            // Global/English Defaults (Top 20)
            defaults = [
                WebBookmark(title: "Google", url: "https://www.google.com"),
                WebBookmark(title: "YouTube", url: "https://www.youtube.com"),
                WebBookmark(title: "Facebook", url: "https://www.facebook.com"),
                WebBookmark(title: "Amazon", url: "https://www.amazon.com"),
                WebBookmark(title: "Wikipedia", url: "https://www.wikipedia.org"),
                WebBookmark(title: "Reddit", url: "https://www.reddit.com"),
                WebBookmark(title: "Netflix", url: "https://www.netflix.com"),
                WebBookmark(title: "LinkedIn", url: "https://www.linkedin.com"),
                WebBookmark(title: "GitHub", url: "https://github.com"),
                WebBookmark(title: "Stack Overflow", url: "https://stackoverflow.com"),
                WebBookmark(title: "X (Twitter)", url: "https://twitter.com"),
                WebBookmark(title: "Instagram", url: "https://www.instagram.com"),
                WebBookmark(title: "Twitch", url: "https://www.twitch.tv"),
                WebBookmark(title: "IMDb", url: "https://www.imdb.com"),
                WebBookmark(title: "CNN", url: "https://www.cnn.com"),
                WebBookmark(title: "Microsoft", url: "https://www.microsoft.com"),
                WebBookmark(title: "Apple", url: "https://www.apple.com"),
                WebBookmark(title: "ChatGPT", url: "https://chat.openai.com"),
                WebBookmark(title: "Discord", url: "https://discord.com"),
                WebBookmark(title: "Spotify", url: "https://open.spotify.com")
            ]
        }
        
        bookmarks = defaults
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }
    
    func addBookmark(title: String, url: String) {
        let newBookmark = WebBookmark(title: title, url: url)
        bookmarks.append(newBookmark)
        saveBookmarks()
    }
    
    func removeBookmark(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        saveBookmarks()
    }
    
    func removeBookmark(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveBookmarks()
    }
    
    func moveBookmark(from source: IndexSet, to destination: Int) {
        bookmarks.move(fromOffsets: source, toOffset: destination)
        saveBookmarks()
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        saveBookmarks()
    }
    
    func resetBookmarksToDefault() {
        loadDefaultBookmarks()
    }
    
    // MARK: - Search Logic
    func searchBookmarks(query: String) -> [WebBookmark] {
        guard !query.isEmpty else { return bookmarks }
        return bookmarks.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.url.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getSearchURL(for query: String) -> URL? {
        // If query is a valid URL, return it directly
        if let url = URL(string: query), url.scheme != nil, url.host != nil {
            return url
        }
        
        // If query looks like a domain but missing scheme, prepend https://
        if query.contains(".") && !query.contains(" ") {
             if let url = URL(string: "https://" + query), url.host != nil {
                 return url
             }
        }
        
        // Otherwise use search engine
        return selectedSearchEngine.searchURL(for: query)
    }
    
    // MARK: - Export Logic
    func exportBookmarks() -> String {
        var html = """
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <!-- This is an automatically generated file.
             It will be read and overwritten.
             DO NOT EDIT! -->
        <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
        <DL><p>
        """
        
        for bookmark in bookmarks {
            html += "\n    <DT><A HREF=\"\(bookmark.url)\">\(bookmark.title)</A>"
        }
        
        html += "\n</DL><p>"
        return html
    }
    
    // MARK: - Import Logic
    func importBookmarks(from fileURL: URL) throws {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let parsedBookmarks = parseNetscapeBookmarks(html: content)
        
        // Merge with existing bookmarks (avoiding exact duplicates by URL)
        let existingURLs = Set(bookmarks.map { $0.url })
        let newBookmarks = parsedBookmarks.filter { !existingURLs.contains($0.url) }
        
        bookmarks.append(contentsOf: newBookmarks)
        saveBookmarks()
    }
    
    private func parseNetscapeBookmarks(html: String) -> [WebBookmark] {
        var results: [WebBookmark] = []
        
        // Simple regex to find <DT><A HREF="...">Title</A> pattern
        // This is a basic implementation and might miss some edge cases
        let pattern = #"<DT><A HREF="([^"]+)"[^>]*>([^<]+)</A>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if match.numberOfRanges >= 3 {
                let url = nsString.substring(with: match.range(at: 1))
                let title = nsString.substring(with: match.range(at: 2))
                
                results.append(WebBookmark(title: title, url: url))
            }
        }
        
        return results
    }
}
