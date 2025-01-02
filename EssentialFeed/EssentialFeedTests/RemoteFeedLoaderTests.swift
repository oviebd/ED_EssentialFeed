//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/1/25.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    
    func get(from url: URL){ }
}

class HttpClientSpy : HTTPClient{
    var requestedURL: URL?
    override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
   
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
