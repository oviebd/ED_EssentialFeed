//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 20/10/24.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieve: .empty, file: file, line: line)
        }

        func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieveTwice: .empty, file: file, line: line)
        }

        func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueImageFeed().local
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

            expect(sut,toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
        }

        func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueImageFeed().local
            let timestamp = Date()

            insert((feed, timestamp), to: sut)

            expect(sut,toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
        }

        func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
        }

        func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)

            let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
        }

        func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)

            let latestFeed = uniqueImageFeed().local
            let latestTimestamp = Date()
            insert((latestFeed, latestTimestamp), to: sut)

            expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
        }

        func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
        }

        func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

            expect(sut, toRetrieve: .empty, file: file, line: line)
        }

        func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)

            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
        }

        func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert((uniqueImageFeed().local, Date()), to: sut)

            deleteCache(from: sut)

            expect(sut, toRetrieve: .empty, file: file, line: line)
        }

        func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            var completedOperationsInOrder = [XCTestExpectation]()

            let op1 = expectation(description: "Operation 1")
            sut.insert(uniqueImageFeed().local, timeStamp: Date()) { _ in
                completedOperationsInOrder.append(op1)
                op1.fulfill()
            }
            
            let op2 = expectation(description: "Operation 2")
            sut.deleteCacheFeed { _ in
                completedOperationsInOrder.append(op2)
                op2.fulfill()
            }

            let op3 = expectation(description: "Operation 3")
            sut.insert(uniqueImageFeed().local, timeStamp: Date())  { _ in
                completedOperationsInOrder.append(op3)
                op3.fulfill()
            }

            waitForExpectations(timeout: 5.0)

            XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
        }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
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
    func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCacheFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetriveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetriveCacheFeedResult, file: StaticString = #file, line: UInt = #line) {
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
    
}
