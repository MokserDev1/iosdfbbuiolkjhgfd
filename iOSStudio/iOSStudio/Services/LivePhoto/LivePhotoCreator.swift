//
//  LivePhotoCreator.swift
//  iOSStudio
//
//  Creates authentic Apple Live Photos pairing a still JPEG/HEIC and QuickTime MOV.
//  Writes required Apple MakerNote and QuickTime metadata identifiers using AVFoundation and ImageIO.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import UniformTypeIdentifiers

public final class LivePhotoCreator {
    public static let shared = LivePhotoCreator()
    
    private init() {}
    
    public enum LivePhotoError: LocalizedError {
        case assetNotFound
        case exportFailed(String)
        case photoKitAccessDenied
        
        public var errorDescription: String? {
            switch self {
            case .assetNotFound: return "Source media files could not be located."
            case .exportFailed(let reason): return "Live Photo generation failed: \(reason)"
            case .photoKitAccessDenied: return "Photo library access permission denied by user."
            }
        }
    }
    
    /// Generates a real Apple Live Photo pair from a video URL and saves it directly to the Photos Library
    public func createLivePhoto(from videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let assetIdentifier = UUID().uuidString
        let tempDir = AppStorageManager.shared.tempLivePhotoFolder.appendingPathComponent(assetIdentifier)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        
        let outputImageURL = tempDir.appendingPathComponent("still.jpg")
        let outputVideoURL = tempDir.appendingPathComponent("live.mov")
        
        // 1. Extract first frame from video as image
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                // Write image with Apple Content Identifier metadata
                guard self.writeStillImageWithMetadata(image: uiImage, to: outputImageURL, assetIdentifier: assetIdentifier) else {
                    DispatchQueue.main.async { completion(.failure(LivePhotoError.exportFailed("Could not write image metadata."))) }
                    return
                }
                
                // Write QuickTime MOV with Apple Content Identifier track metadata
                self.writeQuickTimeWithMetadata(from: videoURL, to: outputVideoURL, assetIdentifier: assetIdentifier) { videoSuccess, videoErr in
                    guard videoSuccess else {
                        DispatchQueue.main.async { completion(.failure(LivePhotoError.exportFailed(videoErr ?? "Unknown video error"))) }
                        return
                    }
                    
                    // Request PhotoKit authorization and save
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized || status == .limited else {
                            DispatchQueue.main.async { completion(.failure(LivePhotoError.photoKitAccessDenied)) }
                            return
                        }
                        
                        PHPhotoLibrary.shared().performChanges({
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .photo, fileURL: outputImageURL, options: nil)
                            
                            let videoOptions = PHAssetResourceCreationOptions()
                            videoOptions.shouldMoveFile = false
                            request.addResource(with: .pairedVideo, fileURL: outputVideoURL, options: videoOptions)
                        }) { success, error in
                            DispatchQueue.main.async {
                                if success {
                                    AppStorageManager.shared.logOperation("Generated Live Photo with ID \(assetIdentifier) saved to Photos.")
                                    completion(.success(()))
                                } else {
                                    completion(.failure(error ?? LivePhotoError.exportFailed("PhotoKit save failed")))
                                }
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(LivePhotoError.exportFailed(error.localizedDescription)))
                }
            }
        }
    }
    
    private func writeStillImageWithMetadata(image: UIImage, to destinationURL: URL, assetIdentifier: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.95),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let uti = CGImageSourceGetType(source) else { return false }
        
        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, uti, 1, nil) else { return false }
        
        let makerNote: [String: Any] = [
            kCGImagePropertyMakerAppleDictionary as String: [
                "17": assetIdentifier
            ]
        ]
        
        CGImageDestinationAddImageFromSource(destination, source, 0, makerNote as CFDictionary)
        return CGImageDestinationFinalize(destination)
    }
    
    private func writeQuickTimeWithMetadata(from sourceURL: URL, to destinationURL: URL, assetIdentifier: String, completion: @escaping (Bool, String?) -> Void) {
        let asset = AVAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(false, "Cannot create AVAssetExportSession")
            return
        }
        
        let metadataItem = AVMutableMetadataItem()
        metadataItem.keySpace = .quickTimeMetadata
        metadataItem.key = "com.apple.quicktime.content.identifier" as NSString
        metadataItem.value = assetIdentifier as NSString
        
        exportSession.outputURL = destinationURL
        exportSession.outputFileType = .mov
        exportSession.metadata = [metadataItem]
        exportSession.shouldOptimizeForNetworkUse = false
        
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(true, nil)
            } else {
                completion(false, exportSession.error?.localizedDescription)
            }
        }
    }
}

