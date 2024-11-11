//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 11/11/24.
//

import Foundation
public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
