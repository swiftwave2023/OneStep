//
//  AppGridView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI
import AppKit

struct AppGridView: View {
    let apps: [AppItem]
    let onSelect: (AppItem) -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(apps) { app in
                    AppGridItemView(app: app) {
                        onSelect(app)
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 400)
    }
}

struct AppGridItemView: View {
    let app: AppItem
    let onSelect: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                
                Text(app.name)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovering ? Color.primary.opacity(0.05) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
