//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 17/11/24.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
