//
//  WallpaperDetailEditorView.swift
//  iOSStudio
//

import SwiftUI
import Photos
import AVKit

public struct WallpaperDetailEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var storage = AppStorageManager.shared
    
    @State var wallpaper: WallpaperItem
    @State private var showingExportActivity = false
    @State private var exportedURL: URL? = nil
    @State private var isProcessingLivePhoto = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showingInstructions = false
    
    // Crop & Scale adjustments
    @State private var selectedAspectRatio: String = "Lock Screen (9:19.5)"
    @State private var exportResolutionScale: Double = 1.0
    
    private let aspectOptions = ["Lock Screen (9:19.5)", "Home Screen (9:16)", "Square (1:1)", "Original"]
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    let fileURL = storage.wallpapersFolder.appendingPathComponent(wallpaper.fileName)
                    
                    // Preview window
                    ZStack {
                        if wallpaper.isVideo {
                            VideoPlayer(player: AVPlayer(url: fileURL))
                                .frame(height: 380)
                                .cornerRadius(16)
                        } else if let img = UIImage(contentsOfFile: fileURL.path) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 380)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Metadata & Status card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(wallpaper.title)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                wallpaper.isFavorite.toggle()
                                updateItem()
                            }) {
                                Image(systemName: wallpaper.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(wallpaper.isFavorite ? .red : .secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Category")
                                .foregroundColor(.secondary)
                            Spacer()
                            Picker("", selection: $wallpaper.category) {
                                ForEach(WallpaperCategory.allCases) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: wallpaper.category) { _ in
                                updateItem()
                            }
                        }
                        
                        HStack {
                            Text("Resolution")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(wallpaper.width) × \(wallpaper.height) px")
                                .font(.system(.subheadline, design: .monospaced))
                        }
                        
                        HStack {
                            Text("File Size")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ByteCountFormatter.string(fromByteCount: wallpaper.fileSize, countStyle: .file))
                                .font(.system(.subheadline, design: .monospaced))
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // Export & Preparation Tools
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Preparation")
                            .font(.headline)
                        
                        Picker("Target Ratio", selection: $selectedAspectRatio) {
                            ForEach(aspectOptions, id: \.self) { opt in
                                Text(opt).tag(opt)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if wallpaper.isVideo {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Live Wallpaper Generation (Public API)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Pairs QuickTime video track with Apple MakerNote metadata and registers as a genuine Live Photo in PhotoKit.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: generateAndSaveLivePhoto) {
                                    HStack {
                                        if isProcessingLivePhoto {
                                            ProgressView()
                                                .padding(.trailing, 6)
                                        }
                                        Text(isProcessingLivePhoto ? "Generating Live Photo..." : "Create & Save Live Photo to Photos")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(theme.currentAccent)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(isProcessingLivePhoto)
                            }
                            .padding(.top, 4)
                        } else {
                            Button(action: saveToPhotosLibrary) {
                                Label("Save to Photos Media Library", systemImage: "photo.badge.plus")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(theme.currentAccent)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: exportToFileShare) {
                            Label("Share / Export File", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .nativeAppleCard()
                    .padding(.horizontal)
                    
                    // iOS Wallpapers Guide Link
                    Button(action: { showingInstructions = true }) {
                        Label("How to Apply on iOS Lock Screen", systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundColor(theme.currentAccent)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Wallpaper Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: deleteWallpaper) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingInstructions) {
                LockScreenInstructionModalView()
            }
            .sheet(isPresented: $showingExportActivity) {
                if let url = exportedURL {
                    ActivityShareView(activityItems: [url])
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func updateItem() {
        if let idx = storage.wallpapers.firstIndex(where: { $0.id == wallpaper.id }) {
            storage.wallpapers[idx] = wallpaper
            storage.saveWallpapers()
        }
    }
    
    private func deleteWallpaper() {
        let fileURL = storage.wallpapersFolder.appendingPathComponent(wallpaper.fileName)
        try? FileManager.default.removeItem(at: fileURL)
        storage.wallpapers.removeAll(where: { $0.id == wallpaper.id })
        storage.saveWallpapers()
        storage.logOperation("Deleted wallpaper \(wallpaper.title)")
        presentationMode.wrappedValue.dismiss()
    }
    
    private func generateAndSaveLivePhoto() {
        isProcessingLivePhoto = true
        let fileURL = storage.wallpapersFolder.appendingPathComponent(wallpaper.fileName)
        
        LivePhotoCreator.shared.createLivePhoto(from: fileURL) { result in
            isProcessingLivePhoto = false
            switch result {
            case .success:
                alertMessage = "Genuine Apple Live Photo created and saved to your Photo Library! You can now set it as your animated Lock Screen wallpaper in Settings > Wallpaper."
                showingAlert = true
            case .failure(let err):
                alertMessage = err.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private func saveToPhotosLibrary() {
        let fileURL = storage.wallpapersFolder.appendingPathComponent(wallpaper.fileName)
        guard let image = UIImage(contentsOfFile: fileURL.path) else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    alertMessage = "Photo Library access is required to save wallpapers."
                    showingAlert = true
                }
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                alertMessage = "Wallpaper successfully saved to Photos album."
                showingAlert = true
                storage.logOperation("Saved \(wallpaper.title) to iOS Photos album.")
            }
        }
    }
    
    private func exportToFileShare() {
        let fileURL = storage.wallpapersFolder.appendingPathComponent(wallpaper.fileName)
        exportedURL = fileURL
        showingExportActivity = true
    }
}

public struct LockScreenInstructionModalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Official Apple iOS Lock Screen Setup")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("In accordance with Apple security guidelines, third-party applications cannot silently overwrite the device's system Lock Screen without user confirmation. Follow these standard steps:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        StepRow(number: "1", text: "Export or save the desired wallpaper or Live Photo to your Photos Library using the button above.")
                        StepRow(number: "2", text: "Open the system Settings app > Wallpaper (or press and hold on your iOS Lock Screen).")
                        StepRow(number: "3", text: "Tap 'Add New Wallpaper' and choose Photos or Live Photos.")
                        StepRow(number: "4", text: "Select your created wallpaper. For Live Photos, ensure the Live Photo motion icon at the bottom is toggled ON.")
                        StepRow(number: "5", text: "Tap 'Add' in the top-right corner and choose 'Set as Wallpaper Pair'.")
                    }
                    .nativeAppleCard()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Instructions", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

public struct StepRow: View {
    public let number: String
    public let text: String
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Color.blue))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

