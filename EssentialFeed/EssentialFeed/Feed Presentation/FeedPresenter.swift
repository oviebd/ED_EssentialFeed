//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 9/11/24.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}


public final class FeedPresenter {
    private let errorView: ResourceErrorView
    private var loadingView: ResourceLoadingView
    var feedView: FeedView

    public init( feedView: FeedView,loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }

    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "title for the feed view")
    }

    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedPresenter.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with errro: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
   
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
