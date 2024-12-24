//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 11/11/24.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}

