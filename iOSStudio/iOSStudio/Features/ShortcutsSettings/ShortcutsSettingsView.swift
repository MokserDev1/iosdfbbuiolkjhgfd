//
//  ShortcutsSettingsView.swift
//  iOSStudio
//

import SwiftUI

public struct SystemSettingLink: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let icon: String
    public let urlString: String
}

public struct ShortcutsSettingsView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let systemLinks: [SystemSettingLink] = [
        SystemSettingLink(title: "Wallpaper Settings", subtitle: "Direct access to iOS wallpaper picker", icon: "photo.fill", urlString: UIApplication.openSettingsURLString),
        SystemSettingLink(title: "Display & Brightness", subtitle: "Dark mode, text size, and True Tone", icon: "sun.max.fill", urlString: UIApplication.openSettingsURLString),
        SystemSettingLink(title: "Accessibility Settings", subtitle: "Motion, contrast, and display accommodations", icon: "figure.walk.circle.fill", urlString: UIApplication.openSettingsURLString),
        SystemSettingLink(title: "Apple Shortcuts", subtitle: "Launch the automation shortcuts editor", icon: "link.circle.fill", urlString: "shortcuts://")
    ]
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Official iOS URL Schemes & Shortcuts")
                        .font(.headline)
                    Text("Safe, non-jailbreak deep links to official Apple system preferences and the native Shortcuts application.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Quick settings links
                VStack(alignment: .leading, spacing: 10) {
                    Text("System Preferences Navigation")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        ForEach(systemLinks) { link in
                            Button(action: { openURL(link.urlString) }) {
                                HStack(spacing: 12) {
                                    Image(systemName: link.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.currentAccent)
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(link.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(link.subtitle)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Deep Link URL Reference for iOS Studio
                VStack(alignment: .leading, spacing: 10) {
                    Text("iOS Studio In-App URL Schemes")
                        .font(.headline)
                    Text("Use these schemes in Apple Shortcuts or widget actions to deep-link directly into iOS Studio modules:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        DeepLinkRow(scheme: "iosstudio://wallpapers", description: "Opens Wallpaper Studio")
                        DeepLinkRow(scheme: "iosstudio://tendies", description: "Opens Tendies Manager")
                        DeepLinkRow(scheme: "iosstudio://icons", description: "Opens Icon Studio")
                        DeepLinkRow(scheme: "iosstudio://widgets", description: "Opens Widget Studio")
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
            }
            .padding(.vertical)
        }
        .navigationTitle("Shortcuts & System")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            alertMessage = "Unable to open system scheme: \(string)"
            showingAlert = true
        }
    }
}

public struct DeepLinkRow: View {
    public let scheme: String
    public let description: String
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(scheme)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                UIPasteboard.general.string = scheme
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(8)
    }
}

