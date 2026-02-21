import Cocoa
import SwiftUI

@MainActor
class WindowManager: NSObject, NSWindowDelegate {
    static let shared = WindowManager()
    
    var window: NSWindow!
    
    private override init() {
        super.init()
        setupWindow()
    }
    
    func setupWindow() {
        // Create a window
        // Initial size covers the search bar. Height will be dynamic based on content in future.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 120), 
            styleMask: [.borderless, .fullSizeContentView], 
            backing: .buffered,
            defer: false
        )
        
        // Window attributes
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        // Delegate
        window.delegate = self
        
        // Center window
        window.center()
        
        // Set content view
        // We wrap HomeView in a NSHostingController
        let hostingController = NSHostingController(rootView: HomeView())
        // Ensure the hosting view background is clear
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        window.contentViewController = hostingController
    }
    
    func toggleWindow() {
        if window.isVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    func showWindow() {
        // Re-center every time it shows, or keep last position? 
        // Standard spotlight behavior is re-center usually, but Alfred remembers.
        // For now, let's just center it to be safe.
        window.center()
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    func hideWindow() {
        window.orderOut(nil)
    }
    
    // NSWindowDelegate: Hide window when it loses focus
    func windowDidResignKey(_ notification: Notification) {
        hideWindow()
    }
}
