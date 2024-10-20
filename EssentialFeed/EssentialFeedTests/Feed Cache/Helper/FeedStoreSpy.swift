//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 16/10/24.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    //    typealias DeletionCompletion = (Error?) -> Void
    //    typealias InsertionCompletion = (Error?) -> Void

    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrive
    }

    private(set) var receivedMessages = [ReceivedMessages]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timeStamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrive(completion : @escaping RetrievalCompletion){
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrive)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    func completeRetrievalWithEmptyCache(at index: Int = 0){
        retrievalCompletions[index](.empty)
    }
    func completeRetrievalWith(with feed : [LocalFeedImage], timeStamp : Date, at index: Int = 0){
        retrievalCompletions[index](.found(feed: feed, timestamp: timeStamp))
    }
}
