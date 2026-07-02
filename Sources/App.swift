import SwiftUI
import AppFactoryKit

// Video Compressor — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "videocompressor_pro_yearly"
    static let weekly = "videocompressor_pro_weekly"
}

@MainActor
enum VideoCompressorFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Video Compressor",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "film",
                          title: "Shrink Any Video",
                          message: "Compress videos right on your device — no upload, no waiting."),
                    .init(systemImage: "internaldrive",
                          title: "Free Up Space",
                          message: "Cut file sizes dramatically while keeping videos watchable and shareable.")
                ],
                presentsPaywallOnFinish: true,
                accent: .purple
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Video Compressor Pro",
                subheadline: "Every compression level, save & share freely.",
                benefits: [
                    .init(systemImage: "slider.horizontal.3", title: "All compression levels", subtitle: "640p, 540p and HD 720p"),
                    .init(systemImage: "square.and.arrow.down", title: "Save & share results"),
                    .init(systemImage: "infinity", title: "Unlimited videos"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/VideoCompressor/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/VideoCompressor/privacy.html"),
                style: PaywallStyle(accent: .purple, heroSystemImage: "film.stack")
            )
        )
        return AppFactory(config)
    }
}

@main
struct VideoCompressorApp: App {
    @StateObject private var factory = VideoCompressorFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.purple)
        }
    }
}
