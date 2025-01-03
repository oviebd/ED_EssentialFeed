//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 9/11/24.
//

import Foundation

public final class FeedPresenter {
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "title for the feed view")
    }

//    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
//        FeedViewModel(feed: feed)
//    }
}
