//
//  AppGridView.swift
//  OneStep
//
//  Created by lixiaolong on 2026/2/22.
//

import SwiftUI

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
                    Button {
                        onSelect(app)
                    } label: {
                        VStack(spacing: 8) {
                            Image(nsImage: app.icon)
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
                        .background(Color.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        // Optional: Add hover effect if needed
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 400)
    }
}
