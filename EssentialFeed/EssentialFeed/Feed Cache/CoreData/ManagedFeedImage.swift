//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 20/10/24.
//

import CoreData

extension ManagedFeedImage {
    internal static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }

    internal var local: LocalFeedImage {
        return LocalFeedImage(id: id!, description: imageDescription, location: location, imageURL: url!)
    }
}
