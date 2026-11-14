//
//  ThemeManager.swift
//  iOSStudio
//
//  Created for iOS Studio - Complete Customization Suite.
//

import SwiftUI
import Combine

public enum AppThemeMode: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    public var id: String { rawValue }
}

public enum AccentColorChoice: String, CaseIterable, Identifiable, Codable {
    case blue = "Apple Blue"
    case purple = "Deep Purple"
    case indigo = "Indigo Sapphire"
    case mint = "Mint Green"
    case orange = "Sunset Orange"
    case pink = "Vibrant Pink"
    case graphite = "Graphite Slate"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .blue: return Color(red: 0.0, green: 0.478, blue: 1.0)
        case .purple: return Color(red: 0.686, green: 0.322, blue: 0.871)
        case .indigo: return Color(red: 0.345, green: 0.337, blue: 0.839)
        case .mint: return Color(red: 0.0, green: 0.78, blue: 0.745)
        case .orange: return Color(red: 1.0, green: 0.584, blue: 0.0)
        case .pink: return Color(red: 1.0, green: 0.176, blue: 0.333)
        case .graphite: return Color(red: 0.556, green: 0.556, blue: 0.576)
        }
    }
}

public enum InterfaceDensity: String, CaseIterable, Identifiable, Codable {
    case compact = "Compact"
    case standard = "Standard"
    case spacious = "Spacious"
    
    public var id: String { rawValue }
    
    public var cardPadding: CGFloat {
        switch self {
        case .compact: return 10
        case .standard: return 16
        case .spacious: return 22
        }
    }
    
    public var rowSpacing: CGFloat {
        switch self {
        case .compact: return 8
        case .standard: return 14
        case .spacious: return 20
        }
    }
}

public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @Published public var themeMode: AppThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "app_theme_mode") }
    }
    
    @Published public var accentChoice: AccentColorChoice {
        didSet { UserDefaults.standard.set(accentChoice.rawValue, forKey: "app_accent_choice") }
    }
    
    @Published public var density: InterfaceDensity {
        didSet { UserDefaults.standard.set(density.rawValue, forKey: "app_interface_density") }
    }
    
    @Published public var reduceMotion: Bool {
        didSet { UserDefaults.standard.set(reduceMotion, forKey: "app_reduce_motion") }
    }
    
    @Published public var fontScale: Double {
        didSet { UserDefaults.standard.set(fontScale, forKey: "app_font_scale") }
    }
    
    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: "app_theme_mode") ?? AppThemeMode.system.rawValue
        self.themeMode = AppThemeMode(rawValue: savedTheme) ?? .system
        
        let savedAccent = UserDefaults.standard.string(forKey: "app_accent_choice") ?? AccentColorChoice.blue.rawValue
        self.accentChoice = AccentColorChoice(rawValue: savedAccent) ?? .blue
        
        let savedDensity = UserDefaults.standard.string(forKey: "app_interface_density") ?? InterfaceDensity.standard.rawValue
        self.density = InterfaceDensity(rawValue: savedDensity) ?? .standard
        
        self.reduceMotion = UserDefaults.standard.bool(forKey: "app_reduce_motion")
        let savedScale = UserDefaults.standard.double(forKey: "app_font_scale")
        self.fontScale = savedScale > 0 ? savedScale : 1.0
    }
    
    public var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    public var currentAccent: Color {
        accentChoice.color
    }
}

