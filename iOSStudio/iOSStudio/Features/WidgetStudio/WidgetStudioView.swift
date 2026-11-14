//
//  WidgetStudioView.swift
//  iOSStudio
//

import SwiftUI
import WidgetKit

public struct WidgetStudioView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    @State private var selectedConfig: WidgetConfigurationModel
    @State private var showingSaveAlert = false
    
    private let availableKinds = [
        ("InfoClock", "Clock & System Status"),
        ("Showcase", "Wallpaper Showcase"),
        ("QuickAction", "Studio Deep-Link Launcher")
    ]
    
    private let availableFamilies = [
        ("systemSmall", "Small (2×2)"),
        ("systemMedium", "Medium (4×2)"),
        ("systemLarge", "Large (4×4)")
    ]
    
    public init() {
        let initial = AppStorageManager.shared.savedWidgets.first ?? WidgetConfigurationModel(name: "Default Preset")
        _selectedConfig = State(initialValue: initial)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Live Interactive Widget Preview Canvas
                VStack(spacing: 12) {
                    Text("Live WidgetKit Preview")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    WidgetLiveCanvas(config: selectedConfig)
                        .padding(.vertical, 8)
                    
                    Text("Renders identical layout as deployed to SpringBoard by iOSStudioWidgetExtension.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Configuration Controls
                VStack(alignment: .leading, spacing: 14) {
                    Text("Widget Configuration")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Widget Type")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Kind", selection: $selectedConfig.widgetKind) {
                            ForEach(availableKinds, id: \.0) { kind in
                                Text(kind.1).tag(kind.0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Widget Size")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("Size", selection: $selectedConfig.family) {
                            ForEach(availableFamilies, id: \.0) { fam in
                                Text(fam.1).tag(fam.0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Primary Title")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Title", text: $selectedConfig.titleText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Subtitle / Status Text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Subtitle", text: $selectedConfig.subtitleText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accent Color")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            ColorCircle(color: .blue, hex: "#007AFF", selectedHex: $selectedConfig.accentHex)
                            ColorCircle(color: .purple, hex: "#AF52DE", selectedHex: $selectedConfig.accentHex)
                            ColorCircle(color: .orange, hex: "#FF9500", selectedHex: $selectedConfig.accentHex)
                            ColorCircle(color: .green, hex: "#34C759", selectedHex: $selectedConfig.accentHex)
                            ColorCircle(color: .red, hex: "#FF3B30", selectedHex: $selectedConfig.accentHex)
                        }
                    }
                    
                    Button(action: saveWidgetConfiguration) {
                        Label("Save & Reload Widget Timeline", systemImage: "arrow.clockwise.circle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.currentAccent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Instructions on how to add to Home Screen
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to Add to iOS Home Screen")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("1. Long press any blank space on your iOS Home Screen until apps jiggle.")
                        Text("2. Tap the '+' button in the top left corner.")
                        Text("3. Search for 'iOS Studio' in the widget gallery.")
                        Text("4. Select Small, Medium, or Large and tap 'Add Widget'.")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
            }
            .padding(.vertical)
        }
        .navigationTitle("Widget Studio")
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Widget Updated"),
                message: Text("Configuration saved. WidgetKit Timeline reloaded via WidgetCenter."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func saveWidgetConfiguration() {
        if let idx = storage.savedWidgets.firstIndex(where: { $0.id == selectedConfig.id }) {
            storage.savedWidgets[idx] = selectedConfig
        } else {
            storage.savedWidgets.append(selectedConfig)
        }
        storage.saveWidgets()
        
        // Reload real WidgetKit Timeline
        WidgetCenter.shared.reloadAllTimelines()
        storage.logOperation("Reloaded WidgetCenter timelines for \(selectedConfig.name)")
        showingSaveAlert = true
    }
}

public struct ColorCircle: View {
    public let color: Color
    public let hex: String
    @Binding public var selectedHex: String
    
    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: selectedHex == hex ? 3 : 0)
            )
            .shadow(radius: selectedHex == hex ? 2 : 0)
            .onTapGesture {
                selectedHex = hex
            }
    }
}

public struct WidgetLiveCanvas: View {
    public let config: WidgetConfigurationModel
    
    public var body: some View {
        Group {
            if config.family == "systemSmall" {
                smallView
                    .frame(width: 155, height: 155)
            } else if config.family == "systemLarge" {
                largeView
                    .frame(width: 330, height: 330)
            } else {
                mediumView
                    .frame(width: 330, height: 155)
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(hex: config.accentHex))
                Spacer()
                Text(Date(), style: .time)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(config.titleText)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
            Text(config.subtitleText)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(14)
    }
    
    private var mediumView: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: config.accentHex))
                    Text(config.titleText)
                        .font(.system(size: 16, weight: .bold))
                }
                Text(config.subtitleText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 8) {
                    Label("Custom", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(Date(), style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Date(), style: .time)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: config.accentHex))
                Text("STUDIO")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
    }
    
    private var largeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            mediumView
            Divider()
            Text("Active System Presets")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                PresetBadge(title: "Wallpapers", icon: "photo")
                PresetBadge(title: "Icons", icon: "app.badge")
                PresetBadge(title: "Tendies", icon: "archivebox")
            }
            Spacer()
        }
        .padding(14)
    }
}

public struct PresetBadge: View {
    public let title: String
    public let icon: String
    
    public var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
            Text(title)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(10)
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

