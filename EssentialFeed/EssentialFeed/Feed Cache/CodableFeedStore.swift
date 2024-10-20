//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 19/10/24.
//

import Foundation

public class CodableFeedStore : FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date

        var localfeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
    }

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)queue", qos: .userInitiated, attributes: .concurrent)
    
    let storeURL: URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrive(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.sync {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(cache.localfeed, timestamp: cache.timeStamp))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timeStamp: Date, completion: @escaping InsertionCompletion) {
       
        let storeURL = self.storeURL
        queue.sync (flags: .barrier){
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timeStamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
       
    }

    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        let storeURL = self.storeURL
        queue.sync(flags: .barrier) {
            do{
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            }catch{
                completion(error)
            }
        }
        
      
    }
}