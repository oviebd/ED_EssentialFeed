//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 12/11/24.
//

import CoreData
import Foundation

extension CoreDataFeedStore: FeedStore {
    public func retrive(completion: @escaping RetrievalCompletion) {
        perform { context in

            completion(Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp!)
                }
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in

            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            })
        }
    }

    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}
