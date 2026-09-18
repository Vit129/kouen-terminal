import Foundation
import XCTest
@testable import KouenApp

@MainActor
final class ModelKeyStoreTests: XCTestCase {
    // ponytail: Keychain read/write itself (saveKey/loadKey/deleteKey) has no test here —
    // SecItemAdd needs a code-signed, keychain-access-group-entitled process to behave
    // deterministically, which this test runner isn't. Covering it needs a signed test bundle
    // or a protocol-seam fake in front of Security.framework — upgrade path if this ever flakes
    // in CI. The custom-endpoint metadata below (plain JSON file, no Keychain) is fully testable.

    override func tearDown() {
        for endpoint in ModelKeyStore.loadCustomEndpoints() {
            ModelKeyStore.removeCustomEndpoint(id: endpoint.id)
        }
        super.tearDown()
    }

    func testCustomEndpointRoundTripsThroughJSONFile() {
        let endpoint = CustomModelEndpoint(name: "kouen-test-endpoint", baseURL: "https://example.invalid/v1")
        ModelKeyStore.addCustomEndpoint(endpoint, key: "unused-in-this-assertion")

        let loaded = ModelKeyStore.loadCustomEndpoints()
        XCTAssertTrue(loaded.contains { $0.id == endpoint.id && $0.name == "kouen-test-endpoint" })
    }

    func testRemoveCustomEndpointDropsItFromMetadata() {
        let endpoint = CustomModelEndpoint(name: "kouen-test-endpoint-2", baseURL: "https://example.invalid/v2")
        ModelKeyStore.addCustomEndpoint(endpoint, key: "unused-in-this-assertion")
        XCTAssertTrue(ModelKeyStore.loadCustomEndpoints().contains { $0.id == endpoint.id })

        ModelKeyStore.removeCustomEndpoint(id: endpoint.id)
        XCTAssertFalse(ModelKeyStore.loadCustomEndpoints().contains { $0.id == endpoint.id })
    }
}
