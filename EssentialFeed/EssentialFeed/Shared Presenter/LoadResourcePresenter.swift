//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Habibur Rahman on 29/11/24.
//

import Foundation

public protocol ResourceView{
    func display(_ viewModel: String)
}


public final class LoadResourcePresenter {
    
    public typealias Mapper = (String) -> String
    
    private let errorView: FeedErrorView
    private var loadingView: FeedLoadingView
    private let mapper: Mapper
    var resourceView: ResourceView

    public init( resourceView: ResourceView,loadingView: FeedLoadingView, errorView: FeedErrorView, mapper : @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with errro: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
