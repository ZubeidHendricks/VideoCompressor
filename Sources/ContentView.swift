import SwiftUI
import PhotosUI
import AppFactoryKit

// Video Compressor — pick a video and shrink it on-device with AVFoundation.
// Free tier compresses at 540p; Pro unlocks more levels and saving/sharing.
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory

    @State private var pickerItem: PhotosPickerItem?
    @State private var inputURL: URL?
    @State private var outputURL: URL?
    @State private var inputSize: Int64 = 0
    @State private var outputSize: Int64 = 0
    @State private var level: CompressionLevel = .all[0]
    @State private var isProcessing = false
    @State private var errorText: String?
    @State private var shareItem: ShareItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PhotosPicker(selection: $pickerItem, matching: .videos) {
                    Label(inputURL == nil ? "Choose Video" : "Choose Another", systemImage: "film")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent).tint(.purple)

                if inputURL != nil {
                    sizeCard
                    Picker("Level", selection: $level) {
                        ForEach(CompressionLevel.all) { Text($0.name).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: level) { _, l in
                        if l.isPremium && !factory.subscriptions.isSubscribed {
                            level = .all[0]; factory.presentPaywall(placement: "level_\(l.id)")
                        }
                    }

                    Button { Task { await compress() } } label: {
                        Label(isProcessing ? "Compressing…" : "Compress", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent).tint(.purple)
                    .disabled(isProcessing)
                }

                if outputURL != nil {
                    Button { save() } label: {
                        Label("Save / Share", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)
                }
                if let errorText { Text(errorText).font(.footnote).foregroundStyle(.red) }
                Spacer()
            }
            .padding(20)
            .navigationTitle("Video Compressor")
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
        .sheet(item: $shareItem) { ActivityView(items: $0.items) }
    }

    private var sizeCard: some View {
        HStack {
            VStack { Text("Original").font(.caption).foregroundStyle(.secondary); Text(format(inputSize)).font(.headline) }
            Spacer()
            Image(systemName: "arrow.right")
            Spacer()
            VStack {
                Text("Compressed").font(.caption).foregroundStyle(.secondary)
                Text(outputSize > 0 ? format(outputSize) : "—").font(.headline).foregroundStyle(outputSize > 0 ? .green : .primary)
            }
        }
        .padding().background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.5)))
    }

    private func load(_ item: PhotosPickerItem) async {
        errorText = nil; outputURL = nil; outputSize = 0
        guard let movie = try? await item.loadTransferable(type: Movie.self) else {
            errorText = "Couldn't load that video."; return
        }
        inputURL = movie.url
        inputSize = VideoCompressor.fileSize(movie.url)
    }

    private func compress() async {
        guard let inputURL else { return }
        isProcessing = true; errorText = nil
        defer { isProcessing = false }
        do {
            let out = try await VideoCompressor.compress(inputURL, level: level)
            outputURL = out
            outputSize = VideoCompressor.fileSize(out)
        } catch { errorText = "Compression failed." }
    }

    private func save() {
        factory.requirePremium(feature: "save_video") {
            guard let outputURL else { return }
            shareItem = ShareItem(items: [outputURL])
        }
    }

    private func format(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

struct ShareItem: Identifiable { let id = UUID(); let items: [Any] }

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
