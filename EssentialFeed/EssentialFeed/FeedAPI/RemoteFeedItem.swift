//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 15/10/24.
//

import Foundation

struct RemoteFeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
