//
//  UrlSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 6/10/24.
//

import XCTest


class URLSessionHTTPClient{
    private let session : URLSession
    init(session: URLSession){
        self.session = session
    }
    
    func get(from url: URL){
        session.dataTask(with: url){ _, _, _ in
            
        }
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let url = URL(string: "http://any_url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual([url], session.receivedURLs)
    }
    
    
    
    //Mark - Helpers
    
    private class URLSessionSpy : URLSession{
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask{
    }
    
}
