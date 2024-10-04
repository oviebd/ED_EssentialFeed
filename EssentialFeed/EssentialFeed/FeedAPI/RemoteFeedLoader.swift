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
    
    public enum Result: Equatable  {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping(Result)-> Void) {
        client.get(from: url){ result in
            
            switch result {
            case let .success(data,response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                }else{
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


private struct Root : Decodable{
    let items: [FeedItem]
}


