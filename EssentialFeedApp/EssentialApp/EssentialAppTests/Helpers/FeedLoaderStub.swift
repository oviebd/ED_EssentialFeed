//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 16/11/24.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}

