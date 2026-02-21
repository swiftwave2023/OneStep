//
//  GeneralPageView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/21.
//

import SwiftUI
import KeyboardShortcuts

struct GeneralPageView: View {
    @EnvironmentObject var appModel: AppModel
    
    @AppStorage("showDockIcon") private var showDockIcon = true
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Toggle OneStep:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleOneStep)
                }
            } header: {
                Text("Shortcuts")
            }
            
            Section {
                Toggle("Show Dock Icon", isOn: $showDockIcon)
                    .onChange(of: showDockIcon) { _, newValue in
                        updateDockIconVisibility(show: newValue)
                    }
                
                Toggle("Show Menu Bar Icon", isOn: $showMenuBarIcon)
                    .onChange(of: showMenuBarIcon) { _, newValue in
                        updateMenuBarIconVisibility(show: newValue)
                    }
            } header: {
                Text("Appearance")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }
    
    private func updateDockIconVisibility(show: Bool) {
        // This should be handled by AppDelegate observing the default, 
        // but we can also force an update here if needed.
        // For now, let's just let the AppStorage update the UserDefaults, 
        // and have AppDelegate listen to it or we can call a static method on AppDelegate if we expose one.
        // Or better, send a Notification.
        NotificationCenter.default.post(name: .dockIconVisibilityChanged, object: nil)
    }
    
    private func updateMenuBarIconVisibility(show: Bool) {
        NotificationCenter.default.post(name: .menuBarIconVisibilityChanged, object: nil)
    }
}

extension Notification.Name {
    static let dockIconVisibilityChanged = Notification.Name("dockIconVisibilityChanged")
    static let menuBarIconVisibilityChanged = Notification.Name("menuBarIconVisibilityChanged")
}
