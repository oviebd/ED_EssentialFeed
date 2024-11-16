//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 16/11/24.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
