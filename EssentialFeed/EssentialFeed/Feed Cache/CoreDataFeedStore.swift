//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 20/10/24.
//

import Foundation

public final class CoreDataFeedStore : FeedStore{
  
    public init (){
        
     }
    
    public func retrive(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    
    
}
