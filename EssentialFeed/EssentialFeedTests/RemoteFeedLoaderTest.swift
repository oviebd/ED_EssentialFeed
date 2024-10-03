//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient
    let url : URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedUrl = url
    }

    var requestedUrl: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    func test_init_doesnotRequestDataFromURL() {
        let givenUrl : URL = URL(string: "https://https://a-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client, url: givenUrl)
        XCTAssertNil(client.requestedUrl)
    }

    func test_load_requestDataFromURL() {
        let givenUrl : URL = URL(string: "https://https://a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client : client,url: givenUrl)
        sut.load()
        XCTAssertEqual(givenUrl,client.requestedUrl)
    }
}
