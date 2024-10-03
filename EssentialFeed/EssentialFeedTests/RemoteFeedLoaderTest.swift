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
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
     
    func test_load_requestsDataFromURL() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual([url],client.requestedUrls)
    }
    
    func test_loadTwicw_requestsDataFromURLTwicw() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedUrls, [url,url])
    }
    
    func test_load_deliverErrorOnClientError(){
        let (sut,client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        var capturedError: RemoteFeedLoader.Error?
     
        sut.load(){ error in capturedError = error }
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // Helpers
    private func makeSUT(url : URL =  URL(string: "https://https://a-url.com")!) -> ( sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        
        var requestedUrls: [URL] = [URL]()
        var error : Error?
        func get(from url: URL) {
            requestedUrls.append(url)
        }
        
        func get(from url: URL, completion: (any Error) -> Void) {
            requestedUrls.append(url)
            if let error = error {
                completion(error)
            }
        }
    }
    
}
