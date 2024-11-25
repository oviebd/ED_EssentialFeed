//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 25/11/24.
//

import Foundation

public final class RemoteLoader<Resource> {
      
    private let url: URL
    private let client: HTTPClient
    private let mapper : Mapper
   
  
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = Swift.Result<Resource, Swift.Error>

    public init(client: HTTPClient, url: URL, mapper : @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }

    public func load(completion: @escaping (Result ) -> Void) {
        client.get(from: url) { [weak self] result in

            guard let self = self else { return }
            switch result {
            case let .success(data, response):
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
                break
            }
        }
    }
    
    private func map(_ data : Data, from response : HTTPURLResponse) -> Result {
        do{
            return .success(try mapper(data, response))
        }catch {
            return .failure(Error.invalidData)
        }
    }
}


