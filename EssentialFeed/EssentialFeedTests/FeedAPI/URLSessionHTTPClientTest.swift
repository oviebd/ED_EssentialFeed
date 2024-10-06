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
            
        }.resume()
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
    
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any_url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stubs(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCallcount, 1)
    }
    
    
    
    
    //Mark - Helpers
    
    private class URLSessionSpy : URLSession{
        var receivedURLs = [URL]()
        private var stubs = [URL:URLSessionDataTask]()
        
        func stubs(url : URL,task : URLSessionDataTask){
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask{
        override func resume() {}
    }
   
    private class URLSessionDataTaskSpy : URLSessionDataTask{
        
        var resumeCallcount = 0
        override func resume() {
            resumeCallcount += 1
        }
        
    }
    
}
