import XCTest
@testable import HarnessTerminalKit

extension XCTestCase {
    @MainActor
    func drainRenderPipeline(_ view: HarnessTerminalSurfaceView, file: StaticString = #filePath, line: UInt = #line) {
        let drained = expectation(description: "frame submission and queue completions drained")
        view.testingDrainRenderPipeline { idle in
            XCTAssertTrue(idle, "the render pipeline must settle before inspecting a submitted frame", file: file, line: line)
            drained.fulfill()
        }
        wait(for: [drained], timeout: 3)
    }

    @MainActor
    func drainRenderPipelineAsync(_ view: HarnessTerminalSurfaceView, file: StaticString = #filePath, line: UInt = #line) async {
        let drained = expectation(description: "frame submission and queue completions drained")
        view.testingDrainRenderPipeline { idle in
            XCTAssertTrue(idle, "the render pipeline must settle before inspecting a submitted frame", file: file, line: line)
            drained.fulfill()
        }
        await fulfillment(of: [drained], timeout: 3)
    }
}
