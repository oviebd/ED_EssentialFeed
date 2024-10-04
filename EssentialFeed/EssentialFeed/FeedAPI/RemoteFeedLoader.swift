//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 3/10/24.
//

import Foundation


public enum HTTPClinetResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion : @escaping(HTTPClinetResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url : URL
    private let client : HTTPClient

    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping(Error)-> Void) {
        client.get(from: url){ result in
            
            switch result {
            case .success:
                completion(.invalidData)
                break
            case .failure:
                completion(.connectivity)
                break
            }
            
        }
    }
}


