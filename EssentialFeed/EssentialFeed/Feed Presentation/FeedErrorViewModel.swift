//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 9/11/24.
//

public struct FeedErrorViewModel {
    public let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
