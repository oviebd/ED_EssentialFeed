//
//  NullStore.swift
//  EssentialApp
//
//  Created by Habibur Rahman on 23/12/24.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
    
    func insert(_ data: Data, for url: URL) throws { }
    
    func deleteCacheFeed() throws {
    }
    
    func retrive(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ feed: [LocalFeedImage], timeStamp timestamp: Date) throws{
    }

   
}

