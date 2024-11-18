//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 18/11/24.
//

import EssentialFeed
import Foundation

class InMemoryFeedStore {
    private(set) var feedCache: CacheFeed?
    private var feedImageDataCache: [URL: Data] = [:]

    private init(feedCache: CacheFeed? = nil) {
        self.feedCache = feedCache
    }
}

extension InMemoryFeedStore: FeedStore {
    func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        feedCache = CacheFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }

    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }

    func retrive(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        feedImageDataCache[url] = data
        completion(.success(()))
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(feedImageDataCache[url]))
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }

    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date.distantPast))
    }

    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(feed: [], timestamp: Date()))
    }
}
