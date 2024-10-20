//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 19/10/24.
//

import EssentialFeed
import XCTest

//protocol FeedStoreSpecs {
//    func test_rerieve_deliversEmptyOnEmptyCache()
//    func test_rerieve_hasNoSideEffectsOnEmotyCache()
//    func test_rerieve_deliversFoundValuesOnNonEmptyCache()
//    func test_rerieve_hasNoSideffectsOnNonEmptyCache()
//   
//
//    func test_insert_overridesPreviouslyInsertedcacheValue()
//    func test_insert_deliversErrorOnInsertationError()
//
//    func test_delete_hasNoSideEffectsOnEmptyCache()
//    func test_delete_emptiesPreviouslyInsertedCache()
// 
//
//    func test_storeSideEffects_runSerially()
//}
//
//protocol FailableRetrieveFeedStoreSpecs {
//    func test_rerieve_deliversFailureOnRetrievalError()
//    func test_rerieve_hasNoSideEffectsOnFailure()
//}
//
//protocol FailableInsertFeedStoreSpecs {
//    func test_insert_deliversErrorOnInsertationError()
//    func test_insert_hasNoSideEffectsOnInsertionError()
//}
//
//protocol FailableDeleteFeedStoreSpecs {
//    func test_insert_deliversErrorOnInsertationError()
//}




final class CodableFeedStoreTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        setupEmptyStoreState()
    }

    override func setUp() {
        super.setUp()
        undoStoreSideEffects()
    }

    func test_rerieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrive: .empty)
    }

    func test_rerieve_hasNoSideEffectsOnEmotyCache() {
        expect(makeSUT(), toRetriveTwice: .empty)
    }

    func test_rerieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)
        expect(sut, toRetrive: .found(feed, timestamp: timestamp))
    }

    func test_rerieve_hasNoSideffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)
        expect(sut, toRetriveTwice: .found(feed, timestamp: timestamp))
    }

    func test_rerieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrive: .failure(anyNSError()))
    }

    func test_rerieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetriveTwice: .failure(anyNSError()))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let insertionerror = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionerror, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        let insertionerror = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionerror, "Expected to insert cache successfully")
    }

    
    func test_insert_overridesPreviouslyInsertedcacheValue() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
       
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)
      
        expect(sut, toRetrive: .found(latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertationError() {
        let invalidStoreUrl = URL(string: "invalidUrl")
        let sut = makeSUT(storeURL: invalidStoreUrl)
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with error")
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreUrl = URL(string: "invalidUrl")
        let sut = makeSUT(storeURL: invalidStoreUrl)
        insert((uniqueImageFeed().local, Date()), to: sut)
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

       deleteCache(from: sut)

        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let invalidStoreUrl = cachesDirectory()
        let sut = makeSUT(storeURL: invalidStoreUrl)

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let invalidStoreUrl = cachesDirectory()
        let sut = makeSUT(storeURL: invalidStoreUrl)

        deleteCache(from: sut)
        
        expect(sut, toRetrive: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completionOperationInOder = [XCTestExpectation]()
        let opt1 = expectation(description: "Operation 01")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completionOperationInOder.append(opt1)
            opt1.fulfill()
        }

        let opt2 = expectation(description: "Operation 02")
        sut.deleteCacheFeed { _ in
            completionOperationInOder.append(opt2)
            opt2.fulfill()
        }

        let opt3 = expectation(description: "Operation 03")
        sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
            completionOperationInOder.append(opt3)
            opt3.fulfill()
        }

        waitForExpectations(timeout: 5)
        XCTAssertEqual(completionOperationInOder, [opt1, opt2, opt3], "Expected side-effects to run serially but operations finished in the wrong order")
    }

    // - MARK: Helpers

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "Wait for cache cache insertion")
        sut.insert(cache.feed, timeStamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return insertionError
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCacheFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    private func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetriveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }

    private func expect(_ sut: FeedStore, toRetrive expectedResult: RetriveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrive { retrievedResult in

            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break

            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)

                break

            default:
                XCTFail("Expects to retrieve \(expectedResult) got \(retrievedResult)instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(String(describing: type(of: self).description))s.store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
