//
//  EssentialAppUIAcceptanceTest.swift
//  EssentialAppUIAcceptanceTest
//
//  Created by Habibur Rahman on 17/11/24.
//

import XCTest

final class EssentialAppUIAcceptanceTest: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
            let app = XCUIApplication()

            app.launch()

            XCTAssertEqual(app.cells.count, 22)
        ///    XCTAssertEqual(app.cells.firstMatch.images.count, 1)
        }
}
