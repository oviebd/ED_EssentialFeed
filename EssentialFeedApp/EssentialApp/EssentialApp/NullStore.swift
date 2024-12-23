//
//  NullStore.swift
//  EssentialApp
//
//  Created by Habibur Rahman on 23/12/24.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func retrive(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
