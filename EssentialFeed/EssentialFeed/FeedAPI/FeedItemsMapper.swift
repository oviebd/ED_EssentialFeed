//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 4/10/24.
//

import Foundation

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

  

    internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK , let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
