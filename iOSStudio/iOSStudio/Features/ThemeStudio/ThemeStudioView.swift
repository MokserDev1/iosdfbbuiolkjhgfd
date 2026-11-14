//
//  ThemeStudioView.swift
//  iOSStudio
//

import SwiftUI

public struct ThemeStudioView: View {
    @ObservedObject private var theme = ThemeManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Color mode selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Appearance Mode")
                        .font(.headline)
                    
                    Picker("Appearance", selection: $theme.themeMode) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("Switches the app interface between Light, Dark, or System matching appearance.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Accent Color Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Accent Palette")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(AccentColorChoice.allCases) { choice in
                            Button(action: { theme.accentChoice = choice }) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(choice.color)
                                        .frame(width: 18, height: 18)
                                    Text(choice.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(theme.accentChoice == choice ? choice.color.opacity(0.15) : Color(UIColor.tertiarySystemFill))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.accentChoice == choice ? choice.color : Color.clear, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Interface Density & Layout
                VStack(alignment: .leading, spacing: 12) {
                    Text("Interface Density")
                        .font(.headline)
                    
                    Picker("Density", selection: $theme.density) {
                        ForEach(InterfaceDensity.allCases) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Font Scale Multiplier")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1fx", theme.fontScale))
                                .font(.caption)
                                .foregroundColor(theme.currentAccent)
                        }
                        Slider(value: $theme.fontScale, in: 0.8...1.4, step: 0.1)
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Accessibility & Motion
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accessibility & Motion")
                        .font(.headline)
                    
                    Toggle("Reduce Motion", isOn: $theme.reduceMotion)
                        .tint(theme.currentAccent)
                    
                    Text("Minimizes dynamic transitions and physics animations for maximum battery life and performance on older devices.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Material Architecture Statement
                VStack(alignment: .leading, spacing: 8) {
                    Label("Apple Material Compliance", systemImage: "applelogo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("iOS Studio strictly relies on Apple's standard system materials and secondary grouped surfaces on iOS 15.8.8. No faux blur shaders or fake glass gradients are rendered. On OS releases equipped with Apple Liquid Glass (visionOS / future iOS), official GlassEffect containers are automatically utilized.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
            }
            .padding(.vertical)
        }
        .navigationTitle("Theme Studio")
    }
}

