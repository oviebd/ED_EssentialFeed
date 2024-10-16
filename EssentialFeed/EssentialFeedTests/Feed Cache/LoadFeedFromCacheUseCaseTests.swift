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
        let exp = expectation(description: "wait for load completion")
        let retrievalError = anyNSError()
        var receivedError : Error?
        sut.load{ result in
            switch result{
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected Failure, Got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with : retrievalError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual( receivedError as? NSError, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "wait for load completion")
        var receivedImages : [FeedImage]?
        sut.load{ result in
           
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected Success, got \(result) instead")
                
            }
            
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual( receivedImages, [])
    }
    
    // MARK: - Helpers
   

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
