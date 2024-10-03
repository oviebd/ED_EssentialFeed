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
        sut.load{ _ in}
        XCTAssertEqual([url],client.requestedUrls)
    }
    
    func test_loadTwicw_requestsDataFromURLTwicw() {
        let url : URL = URL(string: "https://https://a-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls, [url,url])
    }
    
    func test_load_deliverErrorOnClientError(){
        let (sut,client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
    
        sut.load(){ capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
    
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    // Helpers
    private func makeSUT(url : URL =  URL(string: "https://https://a-url.com")!) -> ( sut : RemoteFeedLoader, client : HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
      
      
        private var messages = [(url: URL, completion: (Error)-> Void)]()
   
        var requestedUrls: [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping(Error) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error : Error, at index : Int = 0){
            messages[index].completion(error)
        }
    }
    
}
