//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/1/25.
//

import XCTest

class RemoteFeedLoader {
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
}
