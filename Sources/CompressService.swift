import Foundation
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

/// A PhotosPicker-importable movie (gives us a real file URL to compress).
struct Movie: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent("in-\(UUID().uuidString).mov")
            try? FileManager.default.removeItem(at: copy)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Movie(url: copy)
        }
    }
}

struct CompressionLevel: Identifiable, Hashable {
    let id: String
    let name: String
    let preset: String
    let isPremium: Bool
    static let all: [CompressionLevel] = [
        .init(id: "medium", name: "Medium (540p)", preset: AVAssetExportPreset960x540, isPremium: false),
        .init(id: "small", name: "Small (640p)", preset: AVAssetExportPreset640x480, isPremium: true),
        .init(id: "hd", name: "HD (720p)", preset: AVAssetExportPreset1280x720, isPremium: true),
    ]
}

enum CompressError: Error { case failed, cancelled }

struct VideoCompressor {
    static func fileSize(_ url: URL) -> Int64 {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attrs?[.size] as? NSNumber)?.int64Value ?? 0
    }

    static func compress(_ input: URL, level: CompressionLevel) async throws -> URL {
        let asset = AVURLAsset(url: input)
        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("compressed-\(UUID().uuidString).mp4")
        try? FileManager.default.removeItem(at: output)

        guard let export = AVAssetExportSession(asset: asset, presetName: level.preset) else {
            throw CompressError.failed
        }
        export.outputURL = output
        export.outputFileType = .mp4
        export.shouldOptimizeForNetworkUse = true

        await export.export()
        switch export.status {
        case .completed: return output
        case .cancelled: throw CompressError.cancelled
        default: throw CompressError.failed
        }
    }
}

extension AVAssetExportSession {
    /// Bridge the legacy callback API to async for iOS 17.
    func export() async {
        await withCheckedContinuation { cont in
            exportAsynchronously { cont.resume() }
        }
    }
}
