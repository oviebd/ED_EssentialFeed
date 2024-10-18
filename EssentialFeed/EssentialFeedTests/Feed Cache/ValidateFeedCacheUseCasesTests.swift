//
//  ValidateFeedCacheUseCasesTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 18/10/24.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCasesTests: XCTestCase {

    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
    }
    
    func test_validateCache_doesnotDeleteCachesOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages,[.retrive ])
    }
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessthanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievalWith(with: feed.local, timeStamp : lessthanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive])
    }
    
    func test_validateCache_deletesCahceOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievalWith(with: feed.local, timeStamp : sevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
    }
    
    func test_validateCache_deletessCacheOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrievalWith(with: feed.local, timeStamp : moreThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages,[.retrive,.deleteCachedFeed])
    }
    
    func test_validateCache_doesnotDeleteCacheAfterSUTInstanceHasbeenDeAllocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages,[.retrive])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    

}

