//
//  DeleteKeyMonitor.swift
//  OneStep
//
//  Created by Trae on 2026/2/22.
//

import SwiftUI
import AppKit

struct DeleteKeyMonitor: NSViewRepresentable {
    var onUnhandledDelete: () -> Bool // Returns true if handled
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyMonitorNSView()
        view.handler = onUnhandledDelete
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? KeyMonitorNSView {
            view.handler = onUnhandledDelete
        }
    }
    
    class KeyMonitorNSView: NSView {
        var handler: (() -> Bool)?
        private var monitor: Any?
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if window != nil {
                startMonitoring()
            } else {
                stopMonitoring()
            }
        }
        
        func startMonitoring() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self = self else { return event }
                // 51 is Delete (Backspace), 117 is Forward Delete
                if event.keyCode == 51 || event.keyCode == 117 {
                    if let handled = self.handler?(), handled {
                        return nil // Consume event
                    }
                }
                return event
            }
        }
        
        func stopMonitoring() {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }
        
        deinit {
            stopMonitoring()
        }
    }
}
