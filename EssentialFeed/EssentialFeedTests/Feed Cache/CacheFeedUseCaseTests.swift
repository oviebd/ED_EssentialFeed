//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 14/10/24.
//

import EssentialFeed
import XCTest

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class FeedStore {
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    func deleteCacheFeed(){
        deleteCacheFeedCallCount += 1
    }
    func completeDeletion(with error : Error, at index: Int = 0){
        
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesnotDeleteCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesnotRequestCacheInsertationOnDeletonError(){
        let (sut,store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionerror = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionerror)
        XCTAssertEqual(store.insertCallCount, 0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut : LocalFeedLoader, store : FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut,store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
