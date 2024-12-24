//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 16/11/24.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}

//public extension FeedCache {
//    func saveIgnoringResult(_ feed: [FeedImage]) {
//        save(feed) { _ in }
//    }
//}
