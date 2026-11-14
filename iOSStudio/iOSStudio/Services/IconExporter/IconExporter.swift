//
//  IconExporter.swift
//  iOSStudio
//

import UIKit

public struct IconExportPreset {
    public let name: String
    public let width: CGFloat
    public let height: CGFloat
    public let idiom: String
}

public final class IconExporter {
    public static let shared = IconExporter()
    
    public let standardSizes: [IconExportPreset] = [
        IconExportPreset(name: "App Store High-Res", width: 1024, height: 1024, idiom: "universal"),
        IconExportPreset(name: "iPhone Home Screen (60pt @3x)", width: 180, height: 180, idiom: "iphone"),
        IconExportPreset(name: "iPhone Home Screen (60pt @2x)", width: 120, height: 120, idiom: "iphone"),
        IconExportPreset(name: "iPad Pro Home Screen (83.5pt @2x)", width: 167, height: 167, idiom: "ipad"),
        IconExportPreset(name: "iPad Home Screen (76pt @2x)", width: 152, height: 152, idiom: "ipad"),
        IconExportPreset(name: "Spotlight Search (40pt @3x)", width: 120, height: 120, idiom: "universal"),
        IconExportPreset(name: "Settings & System (29pt @3x)", width: 87, height: 87, idiom: "universal"),
        IconExportPreset(name: "Notification Center (20pt @3x)", width: 60, height: 60, idiom: "universal")
    ]
    
    private init() {}
    
    public func renderIcon(from sourceImage: UIImage, targetSize: CGSize, cornerRadiusRatio: CGFloat = 0.0) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Exact pixel size matching targetSize
        format.opaque = cornerRadiusRatio == 0.0
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: targetSize)
            
            if cornerRadiusRatio > 0 {
                let cornerRadius = min(targetSize.width, targetSize.height) * cornerRadiusRatio
                let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
                path.addClip()
            }
            
            sourceImage.draw(in: rect)
        }
    }
    
    public func exportIconBundle(from sourceImage: UIImage, appName: String) -> URL? {
        let fm = FileManager.default
        let bundleFolder = AppStorageManager.shared.exportsFolder.appendingPathComponent("\(appName)_IconSet_\(UUID().uuidString.prefix(6))", isDirectory: true)
        
        do {
            try fm.createDirectory(at: bundleFolder, withIntermediateDirectories: true, attributes: nil)
            
            for preset in standardSizes {
                let rendered = renderIcon(from: sourceImage, targetSize: CGSize(width: preset.width, height: preset.height))
                if let pngData = rendered.pngData() {
                    let fileName = "icon_\(Int(preset.width))x\(Int(preset.height)).png"
                    let fileURL = bundleFolder.appendingPathComponent(fileName)
                    try pngData.write(to: fileURL)
                }
            }
            
            AppStorageManager.shared.logOperation("Rendered and exported icon bundle for \(appName).")
            return bundleFolder
        } catch {
            return nil
        }
    }
}

