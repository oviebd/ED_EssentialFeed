//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 15/10/24.
//

import Foundation

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    
    func deleteCacheFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrive() throws -> CacheFeed?
    
}
