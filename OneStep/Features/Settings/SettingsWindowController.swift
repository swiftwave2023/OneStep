import Cocoa
import SwiftUI

class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()
    
    private var window: NSWindow?
    
    func show() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let settingsView = SettingsView()
            .environmentObject(AppModel.shared)
        
        let hostingController = NSHostingController(rootView: settingsView)
        hostingController.sizingOptions = [.preferredContentSize]
        
        // Define the window
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Configure modern window style
        newWindow.contentViewController = hostingController
        newWindow.title = "Settings"
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        
        // Ensure standard window background behavior
        newWindow.backgroundColor = .windowBackgroundColor
        newWindow.isMovableByWindowBackground = true
        
        // Behavior settings
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.delegate = self
        
        self.window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        // Clear reference to allow recreation on next show, ensuring fresh state if needed
        // or just to cleanup.
        self.window = nil
    }
}
