//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 10/11/24.
//

import Foundation

public class FeedImagePresenter {

    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
