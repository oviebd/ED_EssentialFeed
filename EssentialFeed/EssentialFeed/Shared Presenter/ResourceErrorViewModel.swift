//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 9/11/24.
//

public struct ResourceErrorViewModel {
    public let message: String?

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
