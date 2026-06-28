# VideoCompressor

Generated from niche `video-compressor` (Media, tier A, score 76).

**Utility:** Shrink video size to share/save space
**Primary ASO keyword:** `video compressor`
**Also target:** `compress video`, `reduce video size`, `shrink video`, `video size`
**Paywall hook:** No size limit, batch, keep quality, no ads

> On-device AVFoundation, no API cost = pure margin. Evergreen utility.

## Build it

```bash
brew install xcodegen        # once
cd VideoCompressor
xcodegen generate
open VideoCompressor.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `video-compressor_yearly` and `video-compressor_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.videocompressor`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
