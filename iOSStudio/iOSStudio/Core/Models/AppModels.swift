//
//  AppModels.swift
//  iOSStudio
//

import Foundation
import SwiftUI

public enum WallpaperCategory: String, CaseIterable, Identifiable, Codable {
    case lockScreen = "Lock Screen"
    case homeScreen = "Home Screen"
    case depth = "Depth Effect"
    case dynamic = "Dynamic / Live"
    case minimal = "Minimalist"
    case abstract = "Abstract"
    case photography = "Photography"
    
    public var id: String { rawValue }
}

public struct WallpaperItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var fileName: String
    public var thumbnailName: String?
    public var isVideo: Bool
    public var duration: Double?
    public var category: WallpaperCategory
    public var isFavorite: Bool
    public var createdAt: Date
    public var width: Int
    public var height: Int
    public var fileSize: Int64
    
    public init(
        id: UUID = UUID(),
        title: String,
        fileName: String,
        thumbnailName: String? = nil,
        isVideo: Bool = false,
        duration: Double? = nil,
        category: WallpaperCategory = .lockScreen,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        width: Int = 0,
        height: Int = 0,
        fileSize: Int64 = 0
    ) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.thumbnailName = thumbnailName
        self.isVideo = isVideo
        self.duration = duration
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.width = width
        self.height = height
        self.fileSize = fileSize
    }
}

public struct TendiesPackage: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var originalFileName: String
    public var unpackedFolder: String
    public var fileSize: Int64
    public var dateImported: Date
    public var isFavorite: Bool
    public var isCorrupted: Bool
    public var corruptionReason: String?
    public var descriptorUUIDs: [String]
    public var posterboardType: String
    public var containedFilesCount: Int
    public var previewImageName: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        originalFileName: String,
        unpackedFolder: String,
        fileSize: Int64,
        dateImported: Date = Date(),
        isFavorite: Bool = false,
        isCorrupted: Bool = false,
        corruptionReason: String? = nil,
        descriptorUUIDs: [String] = [],
        posterboardType: String = "PosterBoard Descriptor Archive",
        containedFilesCount: Int = 0,
        previewImageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.originalFileName = originalFileName
        self.unpackedFolder = unpackedFolder
        self.fileSize = fileSize
        self.dateImported = dateImported
        self.isFavorite = isFavorite
        self.isCorrupted = isCorrupted
        self.corruptionReason = corruptionReason
        self.descriptorUUIDs = descriptorUUIDs
        self.posterboardType = posterboardType
        self.containedFilesCount = containedFilesCount
        self.previewImageName = previewImageName
    }
}

public struct CustomIconItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var appName: String
    public var originalImageFileName: String
    public var exportedImageFileName: String
    public var category: String
    public var isFavorite: Bool
    public var targetBundleID: String
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        appName: String,
        originalImageFileName: String,
        exportedImageFileName: String,
        category: String = "Default",
        isFavorite: Bool = false,
        targetBundleID: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.appName = appName
        self.originalImageFileName = originalImageFileName
        self.exportedImageFileName = exportedImageFileName
        self.category = category
        self.isFavorite = isFavorite
        self.targetBundleID = targetBundleID
        self.createdAt = createdAt
    }
}

public struct WidgetConfigurationModel: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var widgetKind: String
    public var family: String
    public var titleText: String
    public var subtitleText: String
    public var accentHex: String
    public var backgroundStyle: String
    public var associatedWallpaperId: UUID?
    public var deepLinkURL: String
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        widgetKind: String = "InfoClock",
        family: String = "systemMedium",
        titleText: String = "iOS Studio",
        subtitleText: String = "Personalized & Active",
        accentHex: String = "#007AFF",
        backgroundStyle: String = "material",
        associatedWallpaperId: UUID? = nil,
        deepLinkURL: String = "iosstudio://home",
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.widgetKind = widgetKind
        self.family = family
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.accentHex = accentHex
        self.backgroundStyle = backgroundStyle
        self.associatedWallpaperId = associatedWallpaperId
        self.deepLinkURL = deepLinkURL
        self.updatedAt = updatedAt
    }
}

