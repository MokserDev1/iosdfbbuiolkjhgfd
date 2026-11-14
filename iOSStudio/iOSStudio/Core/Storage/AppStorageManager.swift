//
//  AppStorageManager.swift
//  iOSStudio
//

import Foundation
import UIKit
import Combine

public final class AppStorageManager: ObservableObject {
    public static let shared = AppStorageManager()
    
    @Published public var wallpapers: [WallpaperItem] = []
    @Published public var tendiesPackages: [TendiesPackage] = []
    @Published public var customIcons: [CustomIconItem] = []
    @Published public var savedWidgets: [WidgetConfigurationModel] = []
    @Published public var recentOperations: [String] = []
    
    private let wallpapersKey = "ios_studio_wallpapers_v1"
    private let tendiesKey = "ios_studio_tendies_v1"
    private let iconsKey = "ios_studio_icons_v1"
    private let widgetsKey = "ios_studio_widgets_v1"
    private let operationsKey = "ios_studio_recent_ops_v1"
    
    public let documentsURL: URL
    public let wallpapersFolder: URL
    public let tendiesFolder: URL
    public let iconsFolder: URL
    public let exportsFolder: URL
    public let tempLivePhotoFolder: URL
    
    private init() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.documentsURL = docs
        self.wallpapersFolder = docs.appendingPathComponent("Wallpapers", isDirectory: true)
        self.tendiesFolder = docs.appendingPathComponent("Tendies", isDirectory: true)
        self.iconsFolder = docs.appendingPathComponent("Icons", isDirectory: true)
        self.exportsFolder = docs.appendingPathComponent("Exports", isDirectory: true)
        self.tempLivePhotoFolder = docs.appendingPathComponent("TempLivePhoto", isDirectory: true)
        
        createDirectories()
        loadAllData()
    }
    
    private func createDirectories() {
        let fm = FileManager.default
        let dirs = [wallpapersFolder, tendiesFolder, iconsFolder, exportsFolder, tempLivePhotoFolder]
        for dir in dirs {
            if !fm.fileExists(atPath: dir.path) {
                try? fm.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
        }
    }
    
    public func logOperation(_ text: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        recentOperations.insert("[\(timestamp)] \(text)", at: 0)
        if recentOperations.count > 30 {
            recentOperations.removeLast()
        }
        UserDefaults.standard.set(recentOperations, forKey: operationsKey)
    }
    
    public func loadAllData() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: wallpapersKey),
           let items = try? decoder.decode([WallpaperItem].self, from: data) {
            self.wallpapers = items
        }
        
        if let data = UserDefaults.standard.data(forKey: tendiesKey),
           let items = try? decoder.decode([TendiesPackage].self, from: data) {
            self.tendiesPackages = items
        }
        
        if let data = UserDefaults.standard.data(forKey: iconsKey),
           let items = try? decoder.decode([CustomIconItem].self, from: data) {
            self.customIcons = items
        }
        
        if let data = UserDefaults.standard.data(forKey: widgetsKey),
           let items = try? decoder.decode([WidgetConfigurationModel].self, from: data) {
            self.savedWidgets = items
        } else {
            // Default initial widget configuration
            self.savedWidgets = [
                WidgetConfigurationModel(
                    name: "Primary Clock & Info",
                    widgetKind: "InfoClock",
                    family: "systemMedium",
                    titleText: "iOS Studio",
                    subtitleText: "Lock & Home Suite Active",
                    accentHex: "#007AFF"
                ),
                WidgetConfigurationModel(
                    name: "Wallpaper Showcase",
                    widgetKind: "Showcase",
                    family: "systemSmall",
                    titleText: "Showcase",
                    subtitleText: "Curated Wallpaper",
                    accentHex: "#5856D6"
                )
            ]
            saveWidgets()
        }
        
        if let ops = UserDefaults.standard.stringArray(forKey: operationsKey) {
            self.recentOperations = ops
        } else {
            self.recentOperations = [
                "Application initialized successfully.",
                "Storage subsystems verified."
            ]
        }
    }
    
    public func saveWallpapers() {
        if let data = try? JSONEncoder().encode(wallpapers) {
            UserDefaults.standard.set(data, forKey: wallpapersKey)
        }
    }
    
    public func saveTendies() {
        if let data = try? JSONEncoder().encode(tendiesPackages) {
            UserDefaults.standard.set(data, forKey: tendiesKey)
        }
    }
    
    public func saveIcons() {
        if let data = try? JSONEncoder().encode(customIcons) {
            UserDefaults.standard.set(data, forKey: iconsKey)
        }
    }
    
    public func saveWidgets() {
        if let data = try? JSONEncoder().encode(savedWidgets) {
            UserDefaults.standard.set(data, forKey: widgetsKey)
        }
    }
    
    public func clearAllCache() {
        let fm = FileManager.default
        try? fm.removeItem(at: tempLivePhotoFolder)
        try? fm.removeItem(at: exportsFolder)
        createDirectories()
        logOperation("Temporary files and caches cleared.")
    }
    
    public func calculateStorageUsed() -> Int64 {
        let fm = FileManager.default
        var total: Int64 = 0
        if let enumerator = fm.enumerator(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let size = resourceValues.fileSize {
                    total += Int64(size)
                }
            }
        }
        return total
    }
}

