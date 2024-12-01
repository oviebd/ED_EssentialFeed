//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 10/11/24.
//


public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
}
