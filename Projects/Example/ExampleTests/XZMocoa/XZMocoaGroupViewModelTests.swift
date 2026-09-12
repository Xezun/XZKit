//
//  XZMocoaGroupViewModelTests.swift
//  XZKit
//
//  Created by 徐臻 on 2026/9/11.
//

import XCTest
import XZKit


final class XZMocoaGroupViewModelTests: XCTestCase, @preconcurrency XZMocoaTableViewModelDelegate {
    
    override class func setUp() {
        
    }
    
    var results = [String]()
    
    func addResult(_ result: String) {
        NSLog("%@", result)
        results.append(result)
    }
    
    func testExample() {
        let model = GroupModel(sections: [["A", "B", "C"], ["D", "E"]])
        let viewModel = XZMocoaTableViewModel.init(model: model)
        viewModel.delegate = self
        viewModel.ready()
        
        let expectation = self.expectation(description: "")
        
        viewModel.performBatchUpdates {
            model.sections = [["A", "B"], ["C", "D", "E"]]
        } completion: { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(results.contains("didMoveCell: (0, 2) => (1, 0)"), "✅ 测试通过");
    }
    
    // XZMocoaTableViewModelDelegate
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didReloadData null: UnsafeMutableRawPointer?) {
        addResult("didReloadData")
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didSelectCellAt indexPath: IndexPath, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        addResult("didSelectCell: (\(indexPath.section), \(indexPath.item))")
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didDeselectCellAt indexPath: IndexPath, animated: Bool) {
        addResult("didDeselectCell: (\(indexPath.section), \(indexPath.item))")
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didReloadCellsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            addResult("didReloadCell: (\(indexPath.section), \(indexPath.item))")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didInsertCellsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            addResult("didInsertCell: (\(indexPath.section), \(indexPath.item))")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didDeleteCellsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            addResult("didDeleteCell: (\(indexPath.section), \(indexPath.item))")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didMoveCellAt indexPath: IndexPath, to newIndexPath: IndexPath) {
        addResult("didMoveCell: (\(indexPath.section), \(indexPath.item)) => (\(newIndexPath.section), \(newIndexPath.item))")
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didReloadSectionsAt sections: IndexSet) {
        for index in sections {
            addResult("didReloadSection: \(index)")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didInsertSectionsAt sections: IndexSet) {
        for index in sections {
            addResult("didInsertSection: \(index)")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didDeleteSectionsAt sections: IndexSet) {
        for index in sections {
            addResult("didDeleteSection: \(index)")
        }
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didMoveSectionAt section: Int, to newSection: Int) {
        addResult("didDeleteCell: \(section) => \(newSection)")
    }
    
    func tableViewModel(_ tableViewModel: XZMocoaTableViewModel, didPerformBatchUpdates batchUpdates: () -> Void, completion: ((Bool) -> Void)? = nil) {
        addResult("didPerformBatchUpdates")
        batchUpdates();
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            completion?(true)
        }
    }

}

fileprivate class GroupModel<T>: NSObject, XZMocoaGroupModel {
    
    var sections: [[T]]
    
    init(sections: [[T]]) {
        self.sections = sections
        super.init()
    }
    
    func mocoa(_ context: Any, numberOfSections null: Any?) -> Int {
        return sections.count
    }
    
    func mocoa(_ context: Any, numberOfCellsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func mocoa(_ context: Any, modelForCellAt indexPath: IndexPath) -> Any? {
        return sections[indexPath.section][indexPath.item]
    }
    
    func mocoa(_ context: Any, kind: XZMocoaKind, numberOfSupplementsInSection section: Int) -> Int {
        return 0
    }
    
    func mocoa(_ context: Any, kind: XZMocoaKind, modelForSupplementAt indexPath: IndexPath) -> Any? {
        return nil
    }
}
