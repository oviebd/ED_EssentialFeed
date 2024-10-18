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
