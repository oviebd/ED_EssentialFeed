//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 9/11/24.
//

import EssentialFeed
import XCTest

final class FeedPresenterTests: XCTestCase {
   
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_map_createViewModel() {
        let feed = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(feed, viewModel.feed)
    }

   
    private func localized(_ key: String, table : String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let table = table
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
