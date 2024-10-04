//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 3/10/24.
//

import Foundation



public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in

            switch result {
            case let .success(data, response):

                do {
                    let items = try FeedItemMapper.map(data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }

                break
            case .failure:
                completion(.failure(.connectivity))
                break
            }
        }
    }
}

