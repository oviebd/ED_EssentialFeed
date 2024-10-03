//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import XCTest

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.requestedUrl = URL(string: "http://a-url.com")
    }
}

class HTTPClient{
    static let shared = HTTPClient()
    private init(){}
    var requestedUrl : URL?
    
}

class RemoteFeedLoaderTest : XCTestCase{
    
    func test_init_doesnotRequestDataFromURL(){
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
           let sut = RemoteFeedLoader()
           sut.load()
           XCTAssertNotNil(client.requestedUrl)
           
       }
    
}



