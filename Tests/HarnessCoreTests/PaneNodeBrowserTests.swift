import Foundation
@testable import HarnessCore
import XCTest

final class PaneNodeBrowserTests: XCTestCase {
    func testBrowserLeafBehavior() {
        let browserLeaf = BrowserLeaf(id: UUID(), url: URL(string: "https://example.com")!)
        let node = PaneNode.browser(browserLeaf)

        // allSurfaceIDs() returns [] for .browser leaf
        XCTAssertEqual(node.allSurfaceIDs(), [])

        // allPaneIDs() returns [leaf.id] for .browser leaf
        XCTAssertEqual(node.allPaneIDs(), [browserLeaf.id])

        // allLeaves() returns [] for .browser leaf
        XCTAssertEqual(node.allLeaves(), [])
    }

    func testBranchWithLeafAndBrowser() {
        let termLeaf = PaneLeaf()
        let browserLeaf = BrowserLeaf(id: UUID(), url: URL(string: "https://example.com")!)
        
        let node = PaneNode.branch(
            direction: .horizontal,
            ratio: 0.5,
            first: .leaf(termLeaf),
            second: .browser(browserLeaf)
        )

        // allLeaves() returns only the termLeaf
        XCTAssertEqual(node.allLeaves(), [termLeaf])
        
        // allPaneIDs() returns both IDs in traversal order
        XCTAssertEqual(node.allPaneIDs(), [termLeaf.id, browserLeaf.id])

        // allSurfaceIDs() returns only termLeaf's surface IDs
        XCTAssertEqual(node.allSurfaceIDs(), termLeaf.surfaceIDs)
    }
}
