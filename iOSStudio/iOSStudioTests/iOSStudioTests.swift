//
//  iOSStudioTests.swift
//  iOSStudioTests
//

import XCTest
@testable import iOSStudio

class iOSStudioTests: XCTestCase {

    func testSystemInspectorReporting() {
        let info = SystemInspector.shared.inspect()
        XCTAssertFalse(info.deviceModel.isEmpty, "Device model should not be empty.")
        XCTAssertFalse(info.systemVersion.isEmpty, "System version should not be empty.")
        XCTAssertFalse(info.nativeResolution.isEmpty, "Resolution should be computed.")
    }

    func testThemeManagerPersistence() {
        let theme = ThemeManager.shared
        theme.themeMode = .dark
        XCTAssertEqual(theme.themeMode, .dark)
        theme.accentChoice = .purple
        XCTAssertEqual(theme.accentChoice, .purple)
    }

    func testCorruptedTendiesDetection() {
        // Create an invalid mock file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("invalid_test.tendies")
        let dummyData = "NOT_A_VALID_ZIP_HEADER".data(using: .utf8)!
        try? dummyData.write(to: tempURL)

        let result = TendiesParser.shared.parseTendiesFile(at: tempURL)
        XCTAssertTrue(result.isCorrupted, "Invalid archive header should be detected as corrupted.")
        XCTAssertNotNil(result.corruptionReason)
    }

    func testIconExporterPresets() {
        let exporter = IconExporter.shared
        XCTAssertGreaterThan(exporter.standardSizes.count, 5, "Standard icon sizes must cover all required idioms.")
        
        let testImage = UIImage()
        let rendered = exporter.renderIcon(from: testImage, targetSize: CGSize(width: 60, height: 60), cornerRadiusRatio: 0.2)
        XCTAssertEqual(rendered.size.width, 60)
        XCTAssertEqual(rendered.size.height, 60)
    }
}
