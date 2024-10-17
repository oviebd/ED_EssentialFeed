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
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessthanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrievalWith(with: feed.local, timeStamp : lessthanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWith(with: feed.local, timeStamp : sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWith(with: feed.local, timeStamp : moreThanSevenDaysOldTimestamp)
        }
    }
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.load{_ in}
        
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
    }
    
    func test_load_doesnotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.load{_ in}
        
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages,[.retrive ])
    }
    
    func test_load_doesnotDeletesCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessthanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.load{_ in}
        store.completeRetrievalWith(with: feed.local, timeStamp : lessthanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive])
    }
    
    func test_load_DeletesCacheOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.load{_ in}
        store.completeRetrievalWith(with: feed.local, timeStamp : sevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
    }
    
    func test_load_DeletesCacheOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.load{_ in}
        store.completeRetrievalWith(with: feed.local, timeStamp : moreThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
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
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models : [FeedImage], local : [LocalFeedImage]) {
        let items = [uniqueImage(), uniqueImage()]
        let localItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)}
        return (items, localItems)
    }
}

private extension Date{
    func adding(days : Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds : TimeInterval) -> Date {
        return self + seconds
    }
}
