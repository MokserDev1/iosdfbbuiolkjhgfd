//
//  IconStudioView.swift
//  iOSStudio
//

import SwiftUI

public struct IconStudioView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    @State private var showingImagePicker = false
    @State private var appNameInput = ""
    @State private var selectedCornerRadiusRatio: Double = 0.2237 // Apple squircle ratio
    @State private var importedImage: UIImage? = nil
    @State private var showingExportSheet = false
    @State private var exportedFolderURL: URL? = nil
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showingShortcutsGuide = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Icon Creation Canvas Card
                VStack(spacing: 14) {
                    Text("App Icon Workshop")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack {
                        if let img = importedImage {
                            Image(uiImage: IconExporter.shared.renderIcon(from: img, targetSize: CGSize(width: 140, height: 140), cornerRadiusRatio: CGFloat(selectedCornerRadiusRatio)))
                                .resizable()
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
                        } else {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(Color(UIColor.tertiarySystemFill))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 32))
                                            .foregroundColor(.secondary)
                                        Text("Import Graphic")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    .onTapGesture {
                        showingImagePicker = true
                    }
                    
                    TextField("App or Action Name (e.g. Messages, Camera)", text: $appNameInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Corner Masking")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(selectedCornerRadiusRatio == 0 ? "Square (Full Bleed)" : "Apple Squircle")
                                .font(.caption)
                                .foregroundColor(theme.currentAccent)
                        }
                        
                        Slider(value: $selectedCornerRadiusRatio, in: 0.0...0.3, step: 0.05)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { showingImagePicker = true }) {
                            Label(importedImage == nil ? "Select Image" : "Change Image", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(UIColor.secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        
                        Button(action: exportCurrentIcon) {
                            Label("Export PNG Bundle", systemImage: "arrow.down.doc.fill")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(importedImage != nil ? theme.currentAccent : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(importedImage == nil)
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Alternate App Icons (In-App Public API)
                VStack(alignment: .leading, spacing: 10) {
                    Text("iOS Studio Alternate Icon")
                        .font(.headline)
                    Text("Change the home screen icon of iOS Studio directly using Apple's official setAlternateIconName API.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        Button(action: { setAlternateAppIcon(name: nil) }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text("Default").font(.caption2).foregroundColor(.white))
                                Text("Sapphire")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Button(action: { setAlternateAppIcon(name: "AppIcon-Dark") }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.black)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text("Dark").font(.caption2).foregroundColor(.white))
                                Text("Midnight")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Button(action: { setAlternateAppIcon(name: "AppIcon-Tinted") }) {
                            VStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.purple)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text("Tint").font(.caption2).foregroundColor(.white))
                                Text("Amethyst")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // System Shortcuts Theming Guide
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Custom App Icons via Shortcuts", systemImage: "link")
                            .font(.headline)
                        Spacer()
                        Button("Guide") { showingShortcutsGuide = true }
                            .font(.subheadline)
                            .foregroundColor(theme.currentAccent)
                    }
                    
                    Text("Because Apple iOS sandbox prevents third-party apps from modifying third-party springboard icons directly without jailbreak, custom icon theming is officially performed via Apple's native Shortcuts app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        if let url = URL(string: "shortcuts://") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        Label("Launch Apple Shortcuts App", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemFill))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .nativeAppleCard()
                .padding(.horizontal)
                
                // Saved Icons
                if !storage.customIcons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exported Icon Archive (\(storage.customIcons.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(storage.customIcons) { icon in
                            HStack(spacing: 12) {
                                let imgPath = storage.iconsFolder.appendingPathComponent(icon.originalImageFileName).path
                                if let img = UIImage(contentsOfFile: imgPath) {
                                    Image(uiImage: img)
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .cornerRadius(10)
                                } else {
                                    Rectangle().fill(Color.secondary).frame(width: 44, height: 44)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(icon.appName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(DateFormatter.localizedString(from: icon.createdAt, dateStyle: .short, timeStyle: .none))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Icon Studio")
        .sheet(isPresented: $showingImagePicker) {
            UnifiedMediaPicker(filter: .images) { url in
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    importedImage = img
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let folder = exportedFolderURL {
                ActivityShareView(activityItems: [folder])
            }
        }
        .sheet(isPresented: $showingShortcutsGuide) {
            ShortcutsTutorialModalView()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func exportCurrentIcon() {
        guard let img = importedImage else { return }
        let name = appNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "CustomApp" : appNameInput
        
        let id = UUID()
        let originalFileName = "\(id.uuidString).png"
        let origURL = storage.iconsFolder.appendingPathComponent(originalFileName)
        
        if let png = img.pngData() {
            try? png.write(to: origURL)
        }
        
        let bundleURL = IconExporter.shared.exportIconBundle(from: img, appName: name)
        
        let customItem = CustomIconItem(
            id: id,
            appName: name,
            originalImageFileName: originalFileName,
            exportedImageFileName: bundleURL?.lastPathComponent ?? originalFileName
        )
        storage.customIcons.insert(customItem, at: 0)
        storage.saveIcons()
        
        exportedFolderURL = bundleURL
        showingExportSheet = true
    }
    
    private func setAlternateAppIcon(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            alertMessage = "Alternate icons are not supported on this device/configuration."
            showingAlert = true
            return
        }
        
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                alertMessage = "Could not change icon: \(error.localizedDescription)"
                showingAlert = true
            } else {
                storage.logOperation("Changed app icon to \(name ?? "Default")")
            }
        }
    }
}

public struct ShortcutsTutorialModalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("How to Apply Custom Icons in iOS")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Apple's official non-jailbreak workflow for customizing home screen app icons:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        StepRow(number: "1", text: "Open the Shortcuts app on your iPhone.")
                        StepRow(number: "2", text: "Tap '+' in the top right corner to create a new shortcut.")
                        StepRow(number: "3", text: "Add action: 'Open App', then select your target app.")
                        StepRow(number: "4", text: "Tap the Share / Info icon and select 'Add to Home Screen'.")
                        StepRow(number: "5", text: "Tap the shortcut icon next to the name, choose 'Choose Photo', and select the icon you exported from Icon Studio.")
                        StepRow(number: "6", text: "Tap 'Add' to place the custom themed icon onto your Home Screen.")
                    }
                    .nativeAppleCard()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Shortcuts Guide", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

