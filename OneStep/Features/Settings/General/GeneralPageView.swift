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
                // Placeholder for LaunchAtLogin if we decide to add it later
                // For now, just a placeholder or basic settings
                Text("More settings coming soon...")
                    .foregroundColor(.secondary)
            } header: {
                Text("General")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }
}
