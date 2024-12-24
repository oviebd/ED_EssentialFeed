//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/12/24.
//

import EssentialFeed
import XCTest

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
