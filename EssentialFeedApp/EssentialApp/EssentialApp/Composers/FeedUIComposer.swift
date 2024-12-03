//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Habibur Rahman on 31/10/24.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
            let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage],FeedViewAdapter>(loader: { feedLoader() })

        let feedController = ListViewController.makeFeedViewController(
            delegate: presentationAdapter,
            title: FeedPresenter.title)

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)

        return feedController
    }
}

private extension ListViewController {
    static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
