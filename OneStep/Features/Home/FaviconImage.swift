//
//  CachedAsyncImage.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/23.
//

import SwiftUI

struct FaviconImage: View {
    let url: URL
    @State private var image: NSImage?
    private let cacheService = ImageCacheService.shared
    
    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .opacity(0.5)
                    .padding(2)
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _, newURL in
            image = nil
            loadImage()
        }
    }
    
    private func loadImage() {
        // 1. Try to get from cache immediately (on main thread for instant feedback if in memory)
        if let cached = cacheService.getCachedImage(for: url) {
            self.image = cached
        }
        
        Task {
            // 2. If we have a cached image, we might want to refresh it occasionally
            // But doing it every time causes flicker if the image is same.
            // Ideally we check if image changed.
            
            if self.image == nil {
                // Not cached, load fresh
                if let loaded = await cacheService.loadImage(from: url) {
                    await MainActor.run {
                        self.image = loaded
                    }
                }
            } else {
                // Already cached. Check for update in background without clearing current image.
                // We only update self.image if the new image is different or just update it (SwiftUI handles diffing if same object?)
                // NSImage equality check is expensive or pointer based.
                // Let's just update.
                if let fresh = await cacheService.downloadAndCache(url: url) {
                     await MainActor.run {
                        self.image = fresh
                     }
                }
            }
        }
    }
}
