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
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    private var cancellable: AnyCancellable?

    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoading()

        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
            
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
                
            }
            
        }, receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        })
    }
}

