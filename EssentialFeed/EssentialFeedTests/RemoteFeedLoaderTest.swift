//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedUrl = url
    }

    var requestedUrl: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    func test_init_doesnotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedUrl)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedUrl)
    }
}
