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



class RemoteFeedLoaderTest: XCTestCase {
    func test_init_doesnotRequestDataFromURL() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let client = HTTPClientSpy()
        _ = makeSUT(url: url)
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(url,client.requestedUrl)
    }
    
    
    // Helpers
    private func makeSUT(url : URL =  URL(string: "https://https://a-url.com")!) -> ( sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?
        
        func get(from url: URL) {
            requestedUrl = url
        }
    }
    
}
