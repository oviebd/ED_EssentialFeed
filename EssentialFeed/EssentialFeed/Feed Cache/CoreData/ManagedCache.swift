//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 20/10/24.
//

import CoreData

extension ManagedCache {
    internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(in: context)
        return ManagedCache(context: context)
    }

    internal var localFeed: [LocalFeedImage] {
        return feed!.compactMap { ($0 as? ManagedFeedImage)?.local }
    }

    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
    }
}
