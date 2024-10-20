//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 4/10/24.
//

import Foundation

public enum HTTPClinetResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClinetResult) -> Void)
}
