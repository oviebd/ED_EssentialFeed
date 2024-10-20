//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 19/10/24.
//

import EssentialFeed
import XCTest


final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

    override func tearDown() {
        super.tearDown()
        setupEmptyStoreState()
    }

    override func setUp() {
        super.setUp()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
  
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        assertThatInsertDeliversNoErrorOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNosideEffectsOnEmptyCache() {

    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_deliversErrorOnInsertionError() {
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: makeSUT())
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }

    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
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
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: makeSUT())
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
        
        expect(sut, toRetrieve: .empty)
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
