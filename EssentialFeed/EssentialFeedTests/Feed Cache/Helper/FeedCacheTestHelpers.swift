//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Habibur Rahman on 18/10/24.
//

import EssentialFeed
import Foundation

public func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

public func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    return (items, localItems)
}


