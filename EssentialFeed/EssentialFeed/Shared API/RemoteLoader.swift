//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 25/11/24.
//

import Foundation

public final class RemoteLoader : FeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result

    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result ) -> Void) {
        client.get(from: url) { [weak self] result in

            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
                break
            }
        }
    }
    
    private static func map(_ data : Data, from response : HTTPURLResponse) -> Result {
        do{
            let items = try FeedItemMapper.map(data, response: response)
            return .success(items)
        }catch {
            return .failure(Error.invalidData)
        }
    }
}


