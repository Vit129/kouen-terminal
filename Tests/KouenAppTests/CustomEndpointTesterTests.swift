import Foundation
import XCTest
@testable import KouenApp

final class CustomEndpointTesterTests: XCTestCase {
    func testBaseURLGetsChatCompletionsAppended() {
        XCTAssertEqual(
            CustomEndpointTester.chatCompletionsURL(baseURL: "https://agione.pro/hyperone/xapi/api/v1")?.absoluteString,
            "https://agione.pro/hyperone/xapi/api/v1/chat/completions"
        )
        XCTAssertEqual(
            CustomEndpointTester.chatCompletionsURL(baseURL: " https://h.example/v1/ ")?.absoluteString,
            "https://h.example/v1/chat/completions"
        )
    }

    func testFullEndpointIsKeptAsIs() {
        XCTAssertEqual(
            CustomEndpointTester.chatCompletionsURL(baseURL: "https://h.example/v1/chat/completions")?.absoluteString,
            "https://h.example/v1/chat/completions"
        )
    }

    func testPlainHTTPOnlyAllowedForLocalhost() {
        XCTAssertNil(CustomEndpointTester.chatCompletionsURL(baseURL: "http://h.example/v1"))
        XCTAssertNil(CustomEndpointTester.chatCompletionsURL(baseURL: "ftp://h.example/v1"))
        XCTAssertNil(CustomEndpointTester.chatCompletionsURL(baseURL: "not a url"))
        XCTAssertNotNil(CustomEndpointTester.chatCompletionsURL(baseURL: "http://localhost:11434/v1"))
    }

    func testRequestCarriesModelBearerKeyAndOneToken() throws {
        let request = try XCTUnwrap(
            CustomEndpointTester.makeRequest(baseURL: "https://h.example/v1", modelID: "m/1", apiKey: "sk-test")
        )
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer sk-test")
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: try XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["model"] as? String, "m/1")
        XCTAssertEqual(body["max_tokens"] as? Int, 1)
    }

    func testClassifyNeverEchoesKeyAndMapsStatuses() {
        XCTAssertTrue(CustomEndpointTester.classify(statusCode: 200, body: Data()).ok)
        XCTAssertTrue(CustomEndpointTester.classify(statusCode: 401, body: Data("sk-secret".utf8)).message.contains("API key"))
        XCTAssertFalse(CustomEndpointTester.classify(statusCode: 401, body: Data("sk-secret".utf8)).message.contains("sk-secret"))
        XCTAssertTrue(CustomEndpointTester.classify(statusCode: 404, body: Data()).message.contains("Base URL"))
        XCTAssertTrue(CustomEndpointTester.classify(statusCode: 400, body: Data("unknown model".utf8)).message.contains("unknown model"))
    }

    func testEmptyModelIDFailsBeforeAnyRequest() async {
        let result = await CustomEndpointTester.test(baseURL: "https://h.example/v1", modelID: " ", apiKey: "k")
        XCTAssertFalse(result.ok)
    }

    func testEndpointSavedBeforeModelFieldStillDecodes() throws {
        let json = Data(#"{"id":"a","name":"n","baseURL":"https://h.example/v1"}"#.utf8)
        let endpoint = try JSONDecoder().decode(CustomModelEndpoint.self, from: json)
        XCTAssertEqual(endpoint.modelID, "")
    }
}
