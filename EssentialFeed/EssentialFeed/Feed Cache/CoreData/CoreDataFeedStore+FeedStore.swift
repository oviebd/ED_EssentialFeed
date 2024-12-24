//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 12/11/24.
//

import CoreData
import Foundation

extension CoreDataFeedStore: FeedStore {
    public func retrive() throws -> CacheFeed? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp!)
                }
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            }
        }
    }

    public func deleteCacheFeed() throws {
        try performSync { context in
            Result {
                try ManagedCache.deleteCache(in: context)
            }
        }
    }
}
