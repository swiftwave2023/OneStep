//
//  ImageCacheService.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/23.
//

import Foundation
import SwiftUI
internal import Combine

class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, NSImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Initialize cache directory
        if let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectory = cacheURL.appendingPathComponent("FaviconCache")
        } else {
            // Fallback (should rarely happen on macOS)
            cacheDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("FaviconCache")
        }
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    // Returns cached image immediately if available
    func getCachedImage(for url: URL) -> NSImage? {
        let key = NSString(string: url.absoluteString)
        
        // 1. Check memory cache
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // 2. Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(filename(for: url))
        if let data = try? Data(contentsOf: fileURL),
           let image = NSImage(data: data) {
            // Update memory cache
            cache.setObject(image, forKey: key)
            return image
        }
        
        return nil
    }
    
    // Asynchronously loads image: returns cached if exists, or downloads if not.
    // Can optionally force refresh.
    func loadImage(from url: URL, forceRefresh: Bool = false) async -> NSImage? {
        if !forceRefresh, let cached = getCachedImage(for: url) {
            return cached
        }
        return await downloadAndCache(url: url)
    }
    
    // Downloads and caches, returning the new image
    func downloadAndCache(url: URL) async -> NSImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = NSImage(data: data) {
                let key = NSString(string: url.absoluteString)
                
                // Save to memory
                cache.setObject(image, forKey: key)
                
                // Save to disk
                let fileURL = cacheDirectory.appendingPathComponent(filename(for: url))
                try? data.write(to: fileURL)
                
                return image
            }
        } catch {
            print("Failed to download image: \(error)")
        }
        return nil
    }
    
    private func filename(for url: URL) -> String {
        // Simple hash of the URL to be safe filename
        let hash = url.absoluteString.hashValue
        return "\(hash).png"
    }
}
