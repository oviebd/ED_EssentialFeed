//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Habibur Rahman on 5/11/24.
//

import EssentialFeed
import XCTest

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
