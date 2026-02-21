//
//  OneStepApp.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
import KeyboardShortcuts

@main
struct OneStepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Settings Window
        Settings {
            SettingsView()
                .environmentObject(AppModel.shared)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "OneStep")
            button.action = #selector(toggleOneStep)
            button.target = self
        }

        // Setup hotkey listener
        KeyboardShortcuts.onKeyUp(for: .toggleOneStep) {
            Task { @MainActor in
                WindowManager.shared.toggleWindow()
            }
        }
        
        // Initialize WindowManager
        Task { @MainActor in
            _ = WindowManager.shared
            WindowManager.shared.showWindow()
        }
    }
    
    @objc func toggleOneStep() {
        Task { @MainActor in
            WindowManager.shared.toggleWindow()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Handle Dock icon click
        Task { @MainActor in
            WindowManager.shared.toggleWindow()
        }
        return true
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        return menu
    }
    
    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
