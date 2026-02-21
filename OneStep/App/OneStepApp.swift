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
    @StateObject var appModel = AppModel.shared
    
    var body: some Scene {
        // We use SettingsWindowController for Settings window to ensure
        // it works correctly with NSStatusItem click action (which is not supported by MenuBarExtra yet)
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register defaults
        UserDefaults.standard.register(defaults: [
            "showDockIcon": true,
            "showMenuBarIcon": true
        ])
        
        // Initial setup
        updateDockIconVisibility()
        updateMenuBarIconVisibility()
        
        // Setup observers
        NotificationCenter.default.addObserver(self, selector: #selector(dockIconVisibilityChanged), name: .dockIconVisibilityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuBarIconVisibilityChanged), name: .menuBarIconVisibilityChanged, object: nil)

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
    
    @objc func dockIconVisibilityChanged() {
        updateDockIconVisibility()
    }
    
    @objc func menuBarIconVisibilityChanged() {
        updateMenuBarIconVisibility()
    }
    
    private func updateDockIconVisibility() {
        let show = UserDefaults.standard.bool(forKey: "showDockIcon")
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // When switching to .regular, the app might need to be activated to show up properly in Dock immediately
        if show {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    private func updateMenuBarIconVisibility() {
        let show = UserDefaults.standard.bool(forKey: "showMenuBarIcon")
        
        if show {
            if statusItem == nil {
                let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                if let button = item.button {
                    button.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "OneStep")
                    button.action = #selector(toggleOneStep)
                    button.target = self
                }
                statusItem = item
            }
        } else {
            // If hidden, remove the item
            statusItem = nil
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
        Task { @MainActor in
            SettingsWindowController.shared.show()
        }
    }
}
