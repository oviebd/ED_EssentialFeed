//
//  UrlSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 6/10/24.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient{
    private let session : URLSession
    init(session: URLSession){
        self.session = session
    }
    
    func get(from url: URL, completion : @escaping (HTTPClinetResult)-> Void){
        session.dataTask(with: url){ _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {

    
    
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any_url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stubs(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _  in
            
        }
        XCTAssertEqual(task.resumeCallcount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any_url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stubs(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
      
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url){ result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Expected failure with error \(error) , got \(result) instead")
            }
       
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
       
    }
    
    
    //Mark - Helpers
    
    private class URLSessionSpy : URLSession{
        private var stubs = [URL:Stub]()
        
        
        private struct Stub{
            let task : URLSessionDataTask
            let error : Error?
        }
        
        func stubs(url : URL,task : URLSessionDataTask = URLSessionDataTaskSpy() , error : Error? = nil){
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
           
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
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
