//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 29/11/24.
//

import EssentialFeed
import XCTest

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {
        }
    }

}
