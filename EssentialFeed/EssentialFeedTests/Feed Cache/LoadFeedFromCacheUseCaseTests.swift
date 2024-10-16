//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 16/10/24.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load{_ in}
        XCTAssertEqual(store.receivedMessages, [.retrive])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            store.completeRetrieval(with : anyNSError())
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    // MARK: - Helpers
   

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    
    private func expect(_ sut:LocalFeedLoader, toCompleteWith expectedResult : LocalFeedLoader.LoadResult, when action: ()-> Void, file: StaticString = #file, line: UInt = #line ){
        
        
        let exp = expectation(description: "wait for load completion")
        sut.load{ receivedResult in
           
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImags), .success(expectedImages)):
                XCTAssertEqual(receivedImags,expectedImages, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError ,expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
       
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
