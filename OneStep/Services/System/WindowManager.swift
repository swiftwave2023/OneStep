import Cocoa
import SwiftUI

@MainActor
class WindowManager: NSObject, NSWindowDelegate {
    static let shared = WindowManager()
    
    var window: OneStepPanel!
    
    private override init() {
        super.init()
        setupWindow()
    }
    
    func setupWindow() {
        // Create a window
        // Initial size covers the search bar. Height will be dynamic based on content in future.
        // Increased height to accommodate potential suggestions list. 
        // Since we use .fullSizeContentView and transparent background, the visual height is determined by SwiftUI content.
        window = OneStepPanel(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 500), 
            styleMask: [.borderless, .fullSizeContentView], 
            backing: .buffered,
            defer: false
        )
        
        // Window attributes
        window.level = .floating
        window.hidesOnDeactivate = true
        window.isFloatingPanel = true
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
        // Allow the hosting controller to resize its view based on content
        hostingController.sizingOptions = [.preferredContentSize]
        
        window.contentViewController = hostingController
    }
    
    private var lastResignKeyTime: Date?
    
    func toggleWindow() {
        if window.isVisible {
            hideWindow()
        } else {
            // Check if we just hid the window due to resignation (e.g. clicking menu bar icon)
            if let last = lastResignKeyTime, Date().timeIntervalSince(last) < 0.2 {
                return
            }
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
        lastResignKeyTime = nil
    }
    
    func hideWindow() {
        window.orderOut(nil)
    }
    
    // NSWindowDelegate: Hide window when it loses focus
    func windowDidResignKey(_ notification: Notification) {
        // Only record resign time if window was visible
        if window.isVisible {
            lastResignKeyTime = Date()
        }
        hideWindow()
    }
}

class OneStepPanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
