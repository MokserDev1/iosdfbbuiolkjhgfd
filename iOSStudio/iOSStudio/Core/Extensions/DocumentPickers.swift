//
//  DocumentPickers.swift
//  iOSStudio
//

import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

public struct ActivityShareView: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]? = nil

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

public struct DocumentImportPickerView: UIViewControllerRepresentable {
    public let onPick: (URL) -> Void

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.image, .movie, .video, .quickTimeMovie, .png, .jpeg]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

public struct TendiesDocumentPickerView: UIViewControllerRepresentable {
    public let onPick: (URL) -> Void

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Uniform type identifier for zip or generic data, catching .tendies extension
        let types: [UTType] = [
            UTType.zip,
            UTType.data,
            UTType.archive
        ]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

public struct UnifiedMediaPicker: UIViewControllerRepresentable {
    public let filter: PHPickerFilter
    public let onSelect: (URL) -> Void

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onSelect: (URL) -> Void
        init(onSelect: @escaping (URL) -> Void) { self.onSelect = onSelect }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let itemProvider = results.first?.itemProvider else { return }

            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    if let url = url {
                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                        try? FileManager.default.copyItem(at: url, to: temp)
                        DispatchQueue.main.async { self.onSelect(temp) }
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                    if let url = url {
                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + url.pathExtension)
                        try? FileManager.default.copyItem(at: url, to: temp)
                        DispatchQueue.main.async { self.onSelect(temp) }
                    }
                }
            }
        }
    }
}

