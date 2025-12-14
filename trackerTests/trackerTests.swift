//
//  trackerTests.swift
//  trackerTests
//
//  Created by   Дмитрий Кривенко on 05.09.2025.
//

import XCTest
import SnapshotTesting
@testable import tracker
import CoreData
import Swinject

final class trackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    private func makeMainScreen() -> UIViewController {
        let container = TestCoreDataStack.makeInMemoryContainer()
        let context = container.viewContext

        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)

        let root = TrackersView()
        let nav = UINavigationController(rootViewController: root)
        nav.loadViewIfNeeded()
        return nav
    }

    func test_mainScreen_light() {
        let vc = makeMainScreen()

        let traits = UITraitCollection { t in
            t.userInterfaceStyle = .light
        }
        withSnapshotTesting(record: false) {
            assertSnapshot(
                of: vc,
                as: .image(traits: traits)
            )
        }
    }
    
    func test_mainScreen_dark() {
        let vc = makeMainScreen()

        let traits = UITraitCollection { t in
            t.userInterfaceStyle = .dark
        }
        withSnapshotTesting(record: false) {
            assertSnapshot(
                of: vc,
                as: .image(traits: traits)
            )
        }
    }
}
