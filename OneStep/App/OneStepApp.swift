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
        // MenuBar Extra
        MenuBarExtra("OneStep", systemImage: "magnifyingglass") {
            MenuBarView()
        }
        
        // Settings Window
        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(AppModel.shared)
        }
        .windowResizability(.contentSize)
    }
}

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        Button("Toggle OneStep") {
            WindowManager.shared.toggleWindow()
        }
        Divider()
        Button("Settings...") {
            openWindow(id: "settings")
            NSApp.activate(ignoringOtherApps: true)
        }
        .keyboardShortcut(",", modifiers: .command)
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
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
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Handle Dock icon click
        Task { @MainActor in
            WindowManager.shared.toggleWindow()
        }
        return true
    }
}
