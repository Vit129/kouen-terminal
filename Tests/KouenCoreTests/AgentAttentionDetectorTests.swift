import XCTest
@testable import KouenCore

final class AgentAttentionDetectorTests: XCTestCase {

    func testAnsiStripping() {
        let textWithColor = "\u{1b}[31;1mDo you want to proceed?\u{1b}[0m [y/N]"
        let clean = AgentAttentionDetector.stripAnsiSequences(from: textWithColor)
        XCTAssertEqual(clean, "Do you want to proceed? [y/N]")
    }

    func testConfirmationPromptDetection() {
        let prompts = [
            "Do you want to proceed? [y/N]",
            "Apply changes? (y/n)",
            "Delete branch? [yes/no]",
            "Execute command? [Y/n]",
        ]

        for p in prompts {
            let detected = AgentAttentionDetector.detectPrompt(in: p)
            XCTAssertNotNil(detected, "Should detect prompt: \(p)")
            XCTAssertEqual(detected?.kind, .confirmation)
        }
    }

    func testApprovalPromptDetection() {
        let prompts = [
            "Allow tool write_to_file?",
            "Tool approval required: run_command",
            "Do you want to run this command? >",
            "Approve execution of bash script?",
        ]

        for p in prompts {
            let detected = AgentAttentionDetector.detectPrompt(in: p)
            XCTAssertNotNil(detected, "Should detect approval: \(p)")
            XCTAssertEqual(detected?.kind, .approval)
        }
    }

    func testChoicePromptDetection() {
        let prompt = "Select action:\nChoice [1-4]:"
        let detected = AgentAttentionDetector.detectPrompt(in: prompt)
        XCTAssertNotNil(detected)
        XCTAssertEqual(detected?.kind, .choice)
    }

    func testPressEnterDetection() {
        let prompt = "Execution paused. Press Enter to continue..."
        let detected = AgentAttentionDetector.detectPrompt(in: prompt)
        XCTAssertNotNil(detected)
        XCTAssertEqual(detected?.kind, .confirmation)
    }

    func testInteractiveQuestionDetection() {
        let prompt = "? Select an option to configure:"
        let detected = AgentAttentionDetector.detectPrompt(in: prompt)
        XCTAssertNotNil(detected)
        XCTAssertEqual(detected?.kind, .input)
    }

    func testOSC94Detection() {
        let oscData = Data("\u{1b}]9;4;3\u{07}".utf8)
        let detected = AgentAttentionDetector.detectOSC(in: oscData)
        XCTAssertNotNil(detected)
        XCTAssertEqual(detected?.kind, .osc)
    }

    func testNonPromptOutputIgnored() {
        let normalLogs = """
        Building KouenCore...
        Compiling AgentAttentionDetector.swift
        Finished in 2.3s
        """
        let detected = AgentAttentionDetector.detectPrompt(in: normalLogs)
        XCTAssertNil(detected)
    }
}
