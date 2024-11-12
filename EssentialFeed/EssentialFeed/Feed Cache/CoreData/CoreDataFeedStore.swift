//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 20/10/24.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrive(completion: @escaping RetrievalCompletion) {
        perform { context in
            
            completion(Result {
                
                try ManagedCache.find(in: context).map{
                    CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp!)
                }
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            
            completion(Result{
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timeStamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            })
        }
    }

    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result{
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
