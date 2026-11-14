//
//  SystemInspector.swift
//  iOSStudio
//

import UIKit

public struct SystemDeviceInfo {
    public let deviceModel: String
    public let systemName: String
    public let systemVersion: String
    public let deviceName: String
    public let screenWidth: CGFloat
    public let screenHeight: CGFloat
    public let screenScale: CGFloat
    public let nativeResolution: String
    public let totalDiskSpace: String
    public let freeDiskSpace: String
    public let supportsLiquidGlass: Bool
    public let supportsPosterBoard: Bool
    public let supportsAlternateIcons: Bool
    public let isJailbroken: Bool
}

public final class SystemInspector {
    public static let shared = SystemInspector()
    
    private init() {}
    
    public func inspect() -> SystemDeviceInfo {
        let device = UIDevice.current
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        
        let width = bounds.width * scale
        let height = bounds.height * scale
        let resolution = "\(Int(width)) × \(Int(height)) px (@\(Int(scale))x)"
        
        let disk = getDiskSpace()
        
        // Liquid Glass availability: true only on iOS versions having Apple GlassEffectContainer (e.g. visionOS or future iOS versions)
        var liquidGlassSupported = false
        if #available(iOS 26.0, *) {
            liquidGlassSupported = true
        }
        
        // PosterBoard (.tendies system support): Introduced in iOS 16+
        let osVersionNumber = (device.systemVersion as NSString).floatValue
        let posterBoardSupported = osVersionNumber >= 16.0
        
        let altIconsSupported = UIApplication.shared.supportsAlternateIcons
        
        return SystemDeviceInfo(
            deviceModel: getModelIdentifier(),
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            deviceName: device.name,
            screenWidth: bounds.width,
            screenHeight: bounds.height,
            screenScale: scale,
            nativeResolution: resolution,
            totalDiskSpace: disk.total,
            freeDiskSpace: disk.free,
            supportsLiquidGlass: liquidGlassSupported,
            supportsPosterBoard: posterBoardSupported,
            supportsAlternateIcons: altIconsSupported,
            isJailbroken: false
        )
    }
    
    private func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.isEmpty ? UIDevice.current.model : identifier
    }
    
    private func getDiskSpace() -> (total: String, free: String) {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey])
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            
            let total = formatter.string(fromByteCount: Int64(values.volumeTotalCapacity ?? 0))
            let free = formatter.string(fromByteCount: values.volumeAvailableCapacityForImportantUsage ?? 0)
            return (total, free)
        } catch {
            return ("Unknown", "Unknown")
        }
    }
}

