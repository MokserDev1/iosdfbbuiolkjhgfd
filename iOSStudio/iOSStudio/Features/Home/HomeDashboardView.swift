//
//  HomeDashboardView.swift
//  iOSStudio
//

import SwiftUI

public struct HomeDashboardView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    @State private var deviceInfo = SystemInspector.shared.inspect()
    @State private var showingInfoSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: theme.density.rowSpacing + 4) {
                    
                    // Header card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iOS Studio")
                                    .font(.system(size: 28 * theme.fontScale, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("Personalization & Design Center")
                                    .font(.system(size: 14 * theme.fontScale, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // App Icon miniature
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(theme.currentAccent)
                                .padding(12)
                                .background(Circle().fill(theme.currentAccent.opacity(0.12)))
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // Device info overview card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Device & Environment", systemImage: "iphone")
                                .font(.system(size: 16 * theme.fontScale, weight: .semibold))
                            Spacer()
                            Text(deviceInfo.systemName + " " + deviceInfo.systemVersion)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(theme.currentAccent)
                        }
                        
                        Divider()
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Model")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(deviceInfo.deviceModel)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            Spacer()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Screen")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(deviceInfo.nativeResolution)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                            }
                            Spacer()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Storage Available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(deviceInfo.freeDiskSpace)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // System capabilities audit
                    VStack(alignment: .leading, spacing: 10) {
                        Text("System Architecture Capabilities")
                            .font(.system(size: 15 * theme.fontScale, weight: .semibold))
                        
                        HStack {
                            Label("Liquid Glass Native Material", systemImage: deviceInfo.supportsLiquidGlass ? "checkmark.circle.fill" : "info.circle")
                                .font(.subheadline)
                                .foregroundColor(deviceInfo.supportsLiquidGlass ? .green : .secondary)
                            Spacer()
                            Text(deviceInfo.supportsLiquidGlass ? "Supported" : "iOS 15 Native Fallback")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("PosterBoard Lockscreen Daemon", systemImage: deviceInfo.supportsPosterBoard ? "checkmark.circle.fill" : "xmark.circle")
                                .font(.subheadline)
                                .foregroundColor(deviceInfo.supportsPosterBoard ? .green : .orange)
                            Spacer()
                            Text(deviceInfo.supportsPosterBoard ? "Available" : "Requires iOS 16+")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Label("Alternate App Icons API", systemImage: deviceInfo.supportsAlternateIcons ? "checkmark.circle.fill" : "xmark.circle")
                                .font(.subheadline)
                                .foregroundColor(deviceInfo.supportsAlternateIcons ? .green : .secondary)
                            Spacer()
                            Text(deviceInfo.supportsAlternateIcons ? "Active" : "Not Supported")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // Quick Action Shortcuts Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 16 * theme.fontScale, weight: .semibold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            NavigationLink(destination: WallpaperStudioView()) {
                                QuickActionCard(
                                    title: "Wallpaper Studio",
                                    subtitle: "\(storage.wallpapers.count) items",
                                    icon: "photo.on.rectangle.angled",
                                    color: .blue
                                )
                            }
                            
                            NavigationLink(destination: TendiesManagerView()) {
                                QuickActionCard(
                                    title: "Tendies Manager",
                                    subtitle: "\(storage.tendiesPackages.count) packages",
                                    icon: "archivebox.fill",
                                    color: .purple
                                )
                            }
                            
                            NavigationLink(destination: IconStudioView()) {
                                QuickActionCard(
                                    title: "Icon Studio",
                                    subtitle: "\(storage.customIcons.count) custom icons",
                                    icon: "square.grid.2x2.fill",
                                    color: .orange
                                )
                            }
                            
                            NavigationLink(destination: WidgetStudioView()) {
                                QuickActionCard(
                                    title: "Widget Studio",
                                    subtitle: "\(storage.savedWidgets.count) presets",
                                    icon: "square.text.square.fill",
                                    color: .green
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent operations log
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Recent Operations", systemImage: "clock.arrow.circlepath")
                                .font(.system(size: 15 * theme.fontScale, weight: .semibold))
                            Spacer()
                            if !storage.recentOperations.isEmpty {
                                Button("Clear") {
                                    storage.recentOperations.removeAll()
                                    UserDefaults.standard.removeObject(forKey: "ios_studio_recent_ops_v1")
                                }
                                .font(.caption)
                                .foregroundColor(theme.currentAccent)
                            }
                        }
                        
                        if storage.recentOperations.isEmpty {
                            Text("No recent operations.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(storage.recentOperations.prefix(5), id: \.self) { op in
                                    Text(op)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsRootView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(theme.currentAccent)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

public struct QuickActionCard: View {
    public let title: String
    public let subtitle: String
    public let icon: String
    public let color: Color
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .nativeAppleCard()
    }
}

