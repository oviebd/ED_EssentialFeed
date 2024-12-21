//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 21/12/24.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
