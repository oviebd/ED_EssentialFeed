//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 9/11/24.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
