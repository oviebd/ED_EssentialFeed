//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 6/11/24.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    private var cancellable: AnyCancellable?

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
            
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
                
            }
            
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        })
    }
}

