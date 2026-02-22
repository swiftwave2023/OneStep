//
//  AppManager.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI
import AppKit
import CoreServices
internal import Combine

struct AppItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let name: String
    let fileSystemName: String
    let path: String
    
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
        let filename = url.deletingPathExtension().lastPathComponent
        
        var name = filename
        
        // 1. Try to get localized name from MDItem (Spotlight Metadata) - Most accurate as seen in Finder
        if let mdItem = MDItemCreateWithURL(kCFAllocatorDefault, url as CFURL),
           let displayName = MDItemCopyAttribute(mdItem, kMDItemDisplayName) as? String {
            name = displayName
        } 
        // 2. Fallback to Bundle Localized Info Dictionary
        else if let bundle = Bundle(url: url) {
            if let localizedInfo = bundle.localizedInfoDictionary,
               let bundleName = localizedInfo["CFBundleDisplayName"] as? String ?? localizedInfo["CFBundleName"] as? String {
                name = bundleName
            } else if let info = bundle.infoDictionary,
                      let bundleName = info["CFBundleDisplayName"] as? String ?? info["CFBundleName"] as? String {
                name = bundleName
            }
        }
        
        // 3. Fallback to URL resource values
         if name == filename,
            let resourceValues = try? url.resourceValues(forKeys: [.localizedNameKey]),
            let localizedName = resourceValues.localizedName {
             name = localizedName
         }
         
         // 4. Manual fallback for Chinese environment if host app is not localized
         // This is necessary because if the host app (OneStep) doesn't declare Chinese support in Info.plist,
         // Bundle(url:) might default to English resources even on a Chinese system.
         let isChineseSystem = Locale.preferredLanguages.first?.hasPrefix("zh") ?? false
         if isChineseSystem {
             if let bundle = Bundle(url: url) {
                  let searchPaths = ["zh-Hans", "zh-CN", "zh-Hant", "zh_TW", "zh"]
                  for lang in searchPaths {
                      if let path = bundle.path(forResource: "InfoPlist", ofType: "strings", inDirectory: "\(lang).lproj"),
                         let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                          if let zhName = dict["CFBundleDisplayName"] as? String ?? dict["CFBundleName"] as? String {
                              name = zhName
                              break
                          }
                      }
                  }
             }
         }
         
         // Remove .app extension if present
        if name.hasSuffix(".app") {
            name = String(name.dropLast(4))
        }
        
        // Generate Pinyin and Initials based on display name
        let pinyin = name.toPinyin()
        let initials = name.toPinyinInitials()
        
        return AppItem(name: name, fileSystemName: filename, path: path, pinyin: pinyin, initials: initials)
    }
    
    func search(text: String) -> [AppItem] {
        guard !text.isEmpty else { return [] }
        let lowerText = text.lowercased()
        
        return apps.filter { app in
            app.name.lowercased().contains(lowerText) ||
            app.fileSystemName.lowercased().contains(lowerText) ||
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
