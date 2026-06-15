import XCTest
@testable import HarnessApp
import HarnessCore

final class HarnessSidebarPanelViewControllerTests: XCTestCase {
    @MainActor
    func testCollapseAndExpandTogglesSidebarRows() {
        let vc = HarnessSidebarPanelViewController()
        _ = vc.view // force loadView()
        
        let initialRowCount = vc.numberOfRows(in: vc.sessionTable)
        XCTAssertGreaterThan(initialRowCount, 0)
        
        // Find the first group header row
        var headerRowIndex: Int?
        var headerView: SessionGroupHeaderRowView?
        for i in 0..<initialRowCount {
            if let view = vc.tableView(vc.sessionTable, viewFor: nil, row: i) as? SessionGroupHeaderRowView {
                headerRowIndex = i
                headerView = view
                break
            }
        }
        
        XCTAssertNotNil(headerRowIndex)
        XCTAssertNotNil(headerView)
        
        guard let toggle = headerView?.onToggleCollapse else {
            XCTFail("onToggleCollapse callback not set on group header view")
            return
        }
        
        // Collapse the group
        toggle()
        
        let collapsedRowCount = vc.numberOfRows(in: vc.sessionTable)
        XCTAssertLessThan(collapsedRowCount, initialRowCount)
        
        // Expand the group again
        toggle()
        
        let expandedRowCount = vc.numberOfRows(in: vc.sessionTable)
        XCTAssertEqual(expandedRowCount, initialRowCount)
    }
}
