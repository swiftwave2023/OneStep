//
//  AppManager.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI
import AppKit
internal import Combine

struct AppItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage
    
    // Cache for search
    let pinyin: String
    let initials: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Make NSImage Sendable for our usage (unchecked is acceptable here as NSImage is thread-safe for reading)
extension NSImage: @unchecked Sendable {}

@MainActor
class AppManager: ObservableObject {
    static let shared = AppManager()
    
    @Published var apps: [AppItem] = []
    @Published var isScanning = false
    
    private init() {
        Task {
            await scanApps()
        }
    }
    
    func scanApps() async {
        isScanning = true
        defer { isScanning = false }
        
        let newApps = await Task.detached {
            let paths = self.findApplications()
            var items: [AppItem] = []
            for path in paths {
                if let item = self.processApp(at: path) {
                    items.append(item)
                }
            }
            return items
        }.value
        
        self.apps = newApps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    
    nonisolated private func findApplications() -> [String] {
        let fileManager = FileManager.default
        let directories = [
            "/Applications",
            "/System/Applications",
            fileManager.homeDirectoryForCurrentUser.path + "/Applications"
        ]
        
        var foundApps: Set<String> = []
        
        for dir in directories {
            guard let urls = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: dir), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { continue }
            
            for url in urls {
                if url.pathExtension == "app" {
                    foundApps.insert(url.path)
                } else if url.hasDirectoryPath {
                     // Check one level deep for apps in subfolders (e.g. Utilities)
                    if let subUrls = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                        for subUrl in subUrls {
                            if subUrl.pathExtension == "app" {
                                foundApps.insert(subUrl.path)
                            }
                        }
                    }
                }
            }
        }
        
        return Array(foundApps)
    }
    
    nonisolated private func processApp(at path: String) -> AppItem? {
        let url = URL(fileURLWithPath: path)
        let name = url.deletingPathExtension().lastPathComponent
        
        // Get icon
        let icon = NSWorkspace.shared.icon(forFile: path)
        
        // Generate Pinyin and Initials
        let pinyin = name.toPinyin()
        let initials = name.toPinyinInitials()
        
        return AppItem(name: name, path: path, icon: icon, pinyin: pinyin, initials: initials)
    }
    
    func search(text: String) -> [AppItem] {
        guard !text.isEmpty else { return [] }
        let lowerText = text.lowercased()
        
        return apps.filter { app in
            app.name.lowercased().contains(lowerText) ||
            app.pinyin.contains(lowerText) ||
            app.initials.contains(lowerText)
        }
    }
    
    func launchApp(_ app: AppItem) {
        let url = URL(fileURLWithPath: app.path)
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                print("Failed to launch app: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - String Extensions for Pinyin
extension String {
    func toPinyin() -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        return (mutableString as String).lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func toPinyinInitials() -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        
        let components = (mutableString as String).components(separatedBy: " ")
        return components.compactMap { $0.first }.map { String($0) }.joined().lowercased()
    }
}
