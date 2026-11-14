//
//  SettingsRootView.swift
//  iOSStudio
//

import SwiftUI

public struct SettingsRootView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    // Wallpapers settings
    @AppStorage("pref_default_export_format") private var defaultExportFormat = "PNG"
    @AppStorage("pref_image_quality") private var imageQuality = 0.95
    @AppStorage("pref_auto_album_creation") private var autoAlbumCreation = true
    
    // Privacy & Storage
    @State private var showingClearCacheAlert = false
    @State private var showingResetAllAlert = false
    @State private var storageUsedText = "Calculating..."
    
    public init() {}
    
    public var body: some View {
        List {
            // Appearance
            Section(header: Text("Appearance")) {
                NavigationLink(destination: ThemeStudioView()) {
                    HStack {
                        Label("Theme & Accent Colors", systemImage: "paintbrush.fill")
                            .foregroundColor(theme.currentAccent)
                        Spacer()
                        Text(theme.accentChoice.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Interface Density")
                    Spacer()
                    Text(theme.density.rawValue)
                        .foregroundColor(.secondary)
                }
            }
            
            // Wallpapers & Media
            Section(header: Text("Wallpapers & Live Photos")) {
                Picker("Default Export Format", selection: $defaultExportFormat) {
                    Text("PNG (Lossless)").tag("PNG")
                    Text("JPEG (High Quality)").tag("JPEG")
                    Text("HEIC (Efficient)").tag("HEIC")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Export Quality")
                        Spacer()
                        Text("\(Int(imageQuality * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $imageQuality, in: 0.5...1.0, step: 0.05)
                }
                
                Toggle("Auto-tag iOS Studio Album", isOn: $autoAlbumCreation)
            }
            
            // Storage Management
            Section(header: Text("Local Storage & Caches")) {
                HStack {
                    Text("Local Space Occupied")
                    Spacer()
                    Text(storageUsedText)
                        .foregroundColor(.secondary)
                }
                
                Button("Clear Temporary Caches") {
                    showingClearCacheAlert = true
                }
                .foregroundColor(.orange)
                
                Button("Reset All Library Data") {
                    showingResetAllAlert = true
                }
                .foregroundColor(.red)
            }
            
            // System Environment
            Section(header: Text("System & Architecture")) {
                NavigationLink(destination: ShortcutsSettingsView()) {
                    Label("Shortcuts & System Schemes", systemImage: "link")
                }
                
                HStack {
                    Text("Deployment Target")
                    Spacer()
                    Text("iOS 15.0+")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Target Device OS")
                    Spacer()
                    Text("iOS 15.8.8 Compliant")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Jailbreak Dependency")
                    Spacer()
                    Text("None (Sandboxed)")
                        .foregroundColor(.green)
                }
            }
            
            // Privacy
            Section(header: Text("Privacy & Security")) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.green)
                    Text("100% Local Processing")
                    Spacer()
                    Text("Offline")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("No data, telemetry, analytics, or user media is ever transmitted over the network. All wallpapers, live photos, and .tendies archives remain strictly on-device.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // About
            Section(header: Text("About")) {
                HStack {
                    Text("Application")
                    Spacer()
                    Text("iOS Studio")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0 (Build 1)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("License")
                    Spacer()
                    Text("MIT Open Source")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .onAppear {
            updateStorageSize()
        }
        .alert(isPresented: $showingClearCacheAlert) {
            Alert(
                title: Text("Clear Cache"),
                message: Text("This will remove temporary Live Photo render files and export scratch directories. Imported wallpapers and .tendies archives will be preserved."),
                primaryButton: .destructive(Text("Clear")) {
                    storage.clearAllCache()
                    updateStorageSize()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func updateStorageSize() {
        let bytes = storage.calculateStorageUsed()
        storageUsedText = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

