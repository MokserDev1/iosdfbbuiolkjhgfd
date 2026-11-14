//
//  TendiesManagerView.swift
//  iOSStudio
//

import SwiftUI
import UniformTypeIdentifiers

public struct TendiesManagerView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    @State private var showingFilePicker = false
    @State private var selectedPackage: TendiesPackage? = nil
    @State private var searchQuery = ""
    @State private var showingInfoAlert = false
    @State private var alertMessage = ""
    
    public init() {}
    
    private var filteredPackages: [TendiesPackage] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return storage.tendiesPackages
        }
        return storage.tendiesPackages.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.originalFileName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search .tendies packages...", text: $searchQuery)
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Disclaimer Banner regarding PosterBoard injection vs App Sandbox
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 18))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("About PosterBoard & .tendies")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Packages are parsed, validated, and extracted locally. System-wide injection into PosterBoard daemon requires iOS 16+ companion backup tools (e.g., Nugget/Cowabunga). Packages can be exported with full descriptor integrity.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            if storage.tendiesPackages.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "archivebox")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No .tendies Packages Imported")
                        .font(.headline)
                    Text("Import .tendies archives or CAPlayground exports to inspect configurations, extract high-res assets, and prepare descriptors.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: { showingFilePicker = true }) {
                        Label("Import .tendies File", systemImage: "doc.badge.plus")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(theme.currentAccent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredPackages) { pkg in
                        Button(action: { selectedPackage = pkg }) {
                            TendiesPackageRowView(pkg: pkg)
                        }
                    }
                    .onDelete(perform: deletePackages)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Tendies Manager")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilePicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.currentAccent)
                }
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            TendiesDocumentPickerView { fileURL in
                importPackage(from: fileURL)
            }
        }
        .sheet(item: $selectedPackage) { pkg in
            TendiesPackageDetailView(package: pkg)
        }
        .alert(isPresented: $showingInfoAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func importPackage(from url: URL) {
        let result = TendiesParser.shared.parseTendiesFile(at: url)
        
        let newPkg = TendiesPackage(
            name: result.packageName,
            originalFileName: result.originalFileName,
            unpackedFolder: result.unpackedDirectory.lastPathComponent,
            fileSize: result.fileSize,
            dateImported: Date(),
            isFavorite: false,
            isCorrupted: result.isCorrupted,
            corruptionReason: result.corruptionReason,
            descriptorUUIDs: result.descriptorUUIDs,
            posterboardType: result.posterboardType,
            containedFilesCount: result.filesCount,
            previewImageName: result.previewImageURL?.lastPathComponent
        )
        
        storage.tendiesPackages.insert(newPkg, at: 0)
        storage.saveTendies()
        storage.logOperation("Parsed .tendies package: \(newPkg.name) (Files: \(newPkg.containedFilesCount))")
        
        if result.isCorrupted {
            alertMessage = "Package imported with warnings: \(result.corruptionReason ?? "Integrity check failed")"
            showingInfoAlert = true
        }
    }
    
    private func deletePackages(at offsets: IndexSet) {
        for idx in offsets {
            let pkg = filteredPackages[idx]
            let folder = storage.tendiesFolder.appendingPathComponent(pkg.unpackedFolder)
            try? FileManager.default.removeItem(at: folder)
            storage.tendiesPackages.removeAll(where: { $0.id == pkg.id })
            storage.logOperation("Deleted .tendies package \(pkg.name)")
        }
        storage.saveTendies()
    }
}

public struct TendiesPackageRowView: View {
    public let pkg: TendiesPackage
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: pkg.isCorrupted ? "exclamationmark.triangle.fill" : "archivebox.fill")
                .font(.system(size: 24))
                .foregroundColor(pkg.isCorrupted ? .orange : .purple)
                .frame(width: 36, height: 36)
                .background(Circle().fill((pkg.isCorrupted ? Color.orange : Color.purple).opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(pkg.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(pkg.posterboardType)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("\(pkg.containedFilesCount) files")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: pkg.fileSize, countStyle: .file))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if pkg.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

public struct TendiesPackageDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var storage = AppStorageManager.shared
    @State var package: TendiesPackage
    @State private var showingShare = false
    @State private var exportURL: URL? = nil
    @State private var extractedImages: [URL] = []
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Header Status
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(package.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text(package.originalFileName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                package.isFavorite.toggle()
                                updatePackage()
                            }) {
                                Image(systemName: package.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Label(package.isCorrupted ? "Integrity Alert" : "Package Verified", systemImage: package.isCorrupted ? "exclamationmark.triangle" : "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundColor(package.isCorrupted ? .orange : .green)
                            Spacer()
                            Text(ByteCountFormatter.string(fromByteCount: package.fileSize, countStyle: .file))
                                .font(.system(.subheadline, design: .monospaced))
                        }
                        
                        if let reason = package.corruptionReason {
                            Text(reason)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // Internal Structure Details
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PosterBoard Architecture")
                            .font(.headline)
                        
                        HStack {
                            Text("Archive Structure")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(package.posterboardType)
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Text("Discovered UUIDs")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(package.descriptorUUIDs.count)")
                                .font(.subheadline)
                        }
                        
                        if !package.descriptorUUIDs.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Descriptors:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(package.descriptorUUIDs, id: \.self) { uuid in
                                    Text(uuid)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: exportPackageArchive) {
                            Label("Export Clean .tendies Package", systemImage: "square.and.arrow.up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: extractWallpapersToStudio) {
                            Label("Extract Images to Wallpaper Studio", systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Package Details", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .sheet(isPresented: $showingShare) {
                if let url = exportURL {
                    ActivityShareView(activityItems: [url])
                }
            }
        }
    }
    
    private func updatePackage() {
        if let idx = storage.tendiesPackages.firstIndex(where: { $0.id == package.id }) {
            storage.tendiesPackages[idx] = package
            storage.saveTendies()
        }
    }
    
    private func exportPackageArchive() {
        let folder = storage.tendiesFolder.appendingPathComponent(package.unpackedFolder)
        exportURL = folder
        showingShare = true
    }
    
    private func extractWallpapersToStudio() {
        let folder = storage.tendiesFolder.appendingPathComponent(package.unpackedFolder)
        let fm = FileManager.default
        
        if let enumerator = fm.enumerator(at: folder, includingPropertiesForKeys: nil) {
            for case let file as URL in enumerator {
                let ext = file.pathExtension.lowercased()
                if ["png", "jpg", "jpeg", "heic"].contains(ext) {
                    let newId = UUID()
                    let destName = "\(newId.uuidString).\(ext)"
                    let destURL = storage.wallpapersFolder.appendingPathComponent(destName)
                    try? fm.copyItem(at: file, to: destURL)
                    
                    let item = WallpaperItem(
                        id: newId,
                        title: "\(package.name) Asset",
                        fileName: destName,
                        category: .lockScreen,
                        fileSize: (try? fm.attributesOfItem(atPath: destURL.path)[.size] as? Int64) ?? 0
                    )
                    storage.wallpapers.insert(item, at: 0)
                }
            }
        }
        storage.saveWallpapers()
        storage.logOperation("Extracted visual assets from \(package.name) to Wallpaper Studio.")
        presentationMode.wrappedValue.dismiss()
    }
}

