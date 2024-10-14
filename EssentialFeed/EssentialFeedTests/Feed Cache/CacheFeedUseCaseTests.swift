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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed{ [unowned self] error in
            if error == nil{
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    var insertions = [(items: [FeedItem], timeStamp : Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    
    func deleteCacheFeed(completion : @escaping DeletionCompletion){
        deleteCacheFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error : Error, at index: Int = 0){
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func insert(_ items : [FeedItem], timeStamp : Date){
        insertCallCount += 1
        insertions.append((items,timeStamp))
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
    
    func test_save_requestNewCacheInsertationOnSuccessfulDeletion(){
        let (sut,store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_requestNewCacheWithTimestampInsertationOnSuccessfulDeletion(){
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut,store) = makeSUT (currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timeStamp, timestamp)
    }

    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut : LocalFeedLoader, store : FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store,currentDate : currentDate)
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
