//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {
    func test_init_doesnotRequestDataFromURL() {
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }
     
    func test_load_requestsDataFromURL() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(url,client.requestedUrl)
    }
    
    func test_loadTwicw_requestsDataFromURLTwicw() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedUrls, [url,url])
    }
    
    // Helpers
    private func makeSUT(url : URL =  URL(string: "https://https://a-url.com")!) -> ( sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?
        var requestedUrls: [URL] = [URL]()
        
        func get(from url: URL) {
            requestedUrl = url
            requestedUrls.append(url)
        }
    }
    
}
