//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 15/10/24.
//

import Foundation
public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timeStamp: Date, completion: @escaping InsertionCompletion)
}


