import XCTest
import Foundation
// CompressService.swift compiled into this test target.

final class CompressTests: XCTestCase {
    func testLevelCatalog() {
        XCTAssertGreaterThanOrEqual(CompressionLevel.all.count, 1)
        XCTAssertFalse(CompressionLevel.all[0].isPremium)   // a free level exists
    }

    func testFileSizeReadsBytes() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("compress-test.bin")
        try Data(repeating: 7, count: 2048).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertEqual(VideoCompressor.fileSize(url), 2048)
    }

    func testMissingFileSizeIsZero() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("does-not-exist-\(UUID()).bin")
        XCTAssertEqual(VideoCompressor.fileSize(url), 0)
    }
}
