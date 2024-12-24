//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 31/10/24.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
