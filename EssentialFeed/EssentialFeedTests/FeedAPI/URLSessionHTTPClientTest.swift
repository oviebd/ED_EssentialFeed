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
    init(session: URLSession = .shared){
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error{}
    
    func get(from url: URL, completion : @escaping (HTTPClinetResult)-> Void){
        session.dataTask(with: url){ _, _, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTest: XCTestCase {
   
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGETRequestsWithURL() {
       
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests{ request in
            XCTAssertEqual(request.url,url)
            XCTAssertEqual(request.httpMethod,"GET")
            exp.fulfill()
        }
        
        makeSut().get(from: url){ _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
      
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        XCTAssertNotNil(receivedError)
    }
    
    //Mark - Helpers
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data:Data?, response : URLResponse?, error :Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
       
        URLProtocolStub.stub(data : data, response : response, error: error)
        let sut = makeSut(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        var receivedError : Error?
        
        sut.get(from: anyURL()){ result in
            switch result{
            case let .failure(error) :
                receivedError = error
                break
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            }
       
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyURL()-> URL{
        return URL(string: "http://any_url.com")!
    }
    
    private class URLProtocolStub : URLProtocol {
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        
        private struct Stub{
            let data : Data?
            let response : URLResponse?
            let error : Error?
        }
        
        static func stub(data : Data?, response : URLResponse?, error : Error?){
            stub = Stub(data: data, response: response,error: error)
        }
        
        static func observeRequests(observer : @escaping (URLRequest) -> Void){
            self.requestObserver = observer
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
 
            if let data = URLProtocolStub.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response{
                client?.urlProtocol(self,  didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
    }

    
}
