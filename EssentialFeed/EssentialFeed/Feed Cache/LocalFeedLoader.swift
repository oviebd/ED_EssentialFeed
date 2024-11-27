//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 15/10/24.
//

import Foundation

public final class LocalFeedLoader  {
   
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calender = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    private var maxCacheAgeInDays: Int {
        return 7
    }

    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
    }
}

extension LocalFeedLoader : FeedCache{
   
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] deletionResult in
            guard let self = self else { return }

            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timeStamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalFeedLoader  {
    
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrive { [weak self] result in

            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where self.validate(cache.timestamp):
                completion(.success(cache.feed.toModels()))
                break
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrive(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCacheFeed(completion: completion)
            case let .success(.some(cache)) where !self.validate(cache.timestamp):
                self.store.deleteCacheFeed(completion: completion)
                break
            case .success:
                completion(.success(()))
            }

        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
