//
//  WallpaperStudioView.swift
//  iOSStudio
//

import SwiftUI
import PhotosUI
import AVKit

public struct WallpaperStudioView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var showingDocumentPicker = false
    @State private var selectedFilterCategory: WallpaperCategory? = nil
    @State private var selectedWallpaper: WallpaperItem? = nil
    @State private var isProcessingLivePhoto = false
    @State private var alertMessage: String? = nil
    @State private var showingAlert = false
    
    public init() {}
    
    private var filteredWallpapers: [WallpaperItem] {
        if let category = selectedFilterCategory {
            return storage.wallpapers.filter { $0.category == category }
        }
        return storage.wallpapers
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // Category selector filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All (\(storage.wallpapers.count))", isSelected: selectedFilterCategory == nil) {
                        selectedFilterCategory = nil
                    }
                    ForEach(WallpaperCategory.allCases) { cat in
                        let count = storage.wallpapers.filter { $0.category == cat }.count
                        FilterChip(title: "\(cat.rawValue) (\(count))", isSelected: selectedFilterCategory == cat) {
                            selectedFilterCategory = cat
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            if storage.wallpapers.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No Wallpapers Imported")
                        .font(.headline)
                    Text("Import high-resolution photos, lock screen assets, or videos to generate Live Wallpapers.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    HStack(spacing: 12) {
                        Button(action: { showingImagePicker = true }) {
                            Label("Import Photo", systemImage: "photo")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(theme.currentAccent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingVideoPicker = true }) {
                            Label("Import Video", systemImage: "video")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(UIColor.secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 8)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(filteredWallpapers) { item in
                            WallpaperGridItemView(item: item)
                                .onTapGesture {
                                    selectedWallpaper = item
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Wallpaper Studio")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingImagePicker = true }) {
                        Label("Import Photo", systemImage: "photo")
                    }
                    Button(action: { showingVideoPicker = true }) {
                        Label("Import Video (for Live Photo)", systemImage: "video")
                    }
                    Button(action: { showingDocumentPicker = true }) {
                        Label("Import from Files", systemImage: "folder")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.currentAccent)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            UnifiedMediaPicker(filter: .images) { url in
                handleImportedFile(url: url, isVideo: false)
            }
        }
        .sheet(isPresented: $showingVideoPicker) {
            UnifiedMediaPicker(filter: .videos) { url in
                handleImportedFile(url: url, isVideo: true)
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentImportPickerView { url in
                let ext = url.pathExtension.lowercased()
                let isVid = ["mov", "mp4", "m4v"].contains(ext)
                handleImportedFile(url: url, isVideo: isVid)
            }
        }
        .sheet(item: $selectedWallpaper) { item in
            WallpaperDetailEditorView(wallpaper: item)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleImportedFile(url: URL, isVideo: Bool) {
        let id = UUID()
        let ext = url.pathExtension.isEmpty ? (isVideo ? "mov" : "jpg") : url.pathExtension
        let destFileName = "\(id.uuidString).\(ext)"
        let destURL = storage.wallpapersFolder.appendingPathComponent(destFileName)
        
        do {
            try FileManager.default.copyItem(at: url, to: destURL)
            let attrs = try FileManager.default.attributesOfItem(atPath: destURL.path)
            let size = attrs[.size] as? Int64 ?? 0
            
            var width = 0
            var height = 0
            var duration: Double? = nil
            
            if isVideo {
                let asset = AVAsset(url: destURL)
                duration = CMTimeGetSeconds(asset.duration)
                if let track = asset.tracks(withMediaType: .video).first {
                    let naturalSize = track.naturalSize
                    width = Int(naturalSize.width)
                    height = Int(naturalSize.height)
                }
            } else {
                if let img = UIImage(contentsOfFile: destURL.path) {
                    width = Int(img.size.width * img.scale)
                    height = Int(img.size.height * img.scale)
                }
            }
            
            let newItem = WallpaperItem(
                id: id,
                title: (url.lastPathComponent as NSString).deletingPathExtension,
                fileName: destFileName,
                thumbnailName: nil,
                isVideo: isVideo,
                duration: duration,
                category: isVideo ? .dynamic : .lockScreen,
                isFavorite: false,
                createdAt: Date(),
                width: width,
                height: height,
                fileSize: size
            )
            
            storage.wallpapers.insert(newItem, at: 0)
            storage.saveWallpapers()
            storage.logOperation("Imported \(isVideo ? "Video" : "Photo") wallpaper: \(newItem.title)")
        } catch {
            alertMessage = "Failed to copy file: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

public struct FilterChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(UIColor.tertiarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

public struct WallpaperGridItemView: View {
    public let item: WallpaperItem
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                let fileURL = AppStorageManager.shared.wallpapersFolder.appendingPathComponent(item.fileName)
                
                if item.isVideo {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .aspectRatio(9/16, contentMode: .fit)
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        )
                } else if let img = UIImage(contentsOfFile: fileURL.path) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minHeight: 180, maxHeight: 220)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 180)
                }
                
                if item.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if item.isVideo {
                        Text("Live/Video")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    } else if item.width > 0 {
                        Text("\(item.width)×\(item.height)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

