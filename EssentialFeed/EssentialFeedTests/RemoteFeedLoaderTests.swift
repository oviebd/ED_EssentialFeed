//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/1/25.
//

import XCTest

class RemoteFeedLoader {
    let client : HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HttpClientSpy : HTTPClient{
    var requestedURL: URL?
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
   
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(client: client)

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)

        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
