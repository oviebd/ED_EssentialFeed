//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 2/10/24.
//

import XCTest

class RemoteFeedLoader{
    
}

class HTTPClient{
    var requestedUrl : URL?
    
}

class RemoteFeedLoaderTest : XCTestCase{
    
    func tesst_init_doesnotRequestDataFromURL(){
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedUrl)
    }
    
}



